#!/bin/sh
set -eu

script_dir=$(dirname "$0")
DOTFILES_DIR=${DOTFILES_DIR:-$(
  CDPATH=
  cd "$script_dir/.." && pwd
)}
MISE_CONFIG=${MISE_CONFIG:-$DOTFILES_DIR/dot_config/mise/config.toml.tmpl}
MISE_TARGET=${MISE_TARGET:-$HOME/.config/mise/config.toml}

is_windows() {
  case "$(uname -s 2>/dev/null || printf unknown)" in
  CYGWIN* | MINGW* | MSYS*) return 0 ;;
  *) return 1 ;;
  esac
}

if is_windows; then
  PATH="/usr/bin:/bin:$PATH"
fi

cargo_bin=${CARGO_HOME:-$HOME/.cargo}/bin
if [ -d "$cargo_bin" ]; then
  case ":$PATH:" in
  *":$cargo_bin:"*) : ;;
  *) PATH="$cargo_bin:$PATH" ;;
  esac
fi

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    printf 'error: rust package install requires %s in PATH\n' "$1" >&2
    return 1
  fi
}

require_rust_package_tools() {
  require_command cargo
  require_command rustc

  host=$(rustc -vV | awk '/^host:/ { print $2 }')
  case "$host" in
  *-pc-windows-gnu)
    for command_name in gcc.exe dlltool.exe ar.exe ld.exe; do
      require_command "$command_name"
    done
    ;;
  esac
}

wanted_packages() {
  awk 'NF && $1 !~ /^#/ { print $1 }' "$1"
}

ruby_protected_gems() {
  ruby -rrubygems -e 'names = Gem::Specification.select(&:default_gem?).map(&:name); begin; require "bundled_gems"; names += Gem::BUNDLED_GEMS.const_defined?(:SINCE) ? Gem::BUNDLED_GEMS::SINCE.keys : []; names += Gem::BUNDLED_GEMS.const_defined?(:EXACT) ? Gem::BUNDLED_GEMS::EXACT.values : []; names += Gem::BUNDLED_GEMS.const_defined?(:PREFIXED) ? Gem::BUNDLED_GEMS::PREFIXED.keys : []; rescue LoadError; end; names += %w[debug rake minitest power_assert rbs repl_type_completor rexml rss rubygems-update test-unit typeprof]; puts names.uniq' | tr -d '\r'
}

ruby_wanted_gems() {
  ruby -rrubygems -e 'wanted = ARGV; specs = Gem::Specification.to_a; names = wanted.dup; queue = wanted.dup; until queue.empty?; name = queue.shift; spec = specs.select { |s| s.name == name }.max_by(&:version); next unless spec; spec.runtime_dependencies.each { |dep| next if names.include?(dep.name); names << dep.name; queue << dep.name }; end; puts names' "$@" | tr -d '\r'
}

update_rubygems() {
  ruby -e 'exit(RUBY_ENGINE == "truffleruby" ? 0 : 1)' || gem update --system
}

confirm_update_mise_tools() {
  printf '%s' 'Update mise tool versions to latest? [y/N] '
  read -r answer
  case "$answer" in
  y | Y | yes | YES) return 0 ;;
  *) return 1 ;;
  esac
}

pin_mise_tools() (
  tools=$(mktemp)
  trap 'rm -f "$tools"' EXIT INT TERM

  perl -ne 'if (/^\s*\[tools\]\s*$/) { $tools=1; next } if (/^\s*\[[A-Za-z0-9_.-]/) { $tools=0 } next unless $tools; next if /^\s*#/; print "$1 $2\n" if /^\s*"?([^"=]+?)"?\s*=\s*"([^"]+)"/' "$MISE_CONFIG" >"$tools"
  while read -r tool current; do
    latest_tool=$tool
    if [ "$tool" = ruby ]; then
      case "$current" in
      truffleruby-[0-9]*.*) latest_tool="ruby@$(printf '%s\n' "$current" | awk -F. '{ print $1 }')" ;;
      truffleruby+graalvm-[0-9]*.*) latest_tool="ruby@$(printf '%s\n' "$current" | awk -F. '{ print $1 }')" ;;
      esac
    fi
    version=$(mise latest "$latest_tool")
    MISE_TOOL="$tool" MISE_VERSION="$version" perl -0pi -e 'BEGIN { $tool=$ENV{MISE_TOOL}; $version=$ENV{MISE_VERSION}; } s/^(\s*"?\Q$tool\E"?\s*=\s*")[^"]+(")/$1$version$2/mg' "$MISE_CONFIG"
  done <"$tools"

  chezmoi apply "$MISE_TARGET"
)

mise_sync() {
  backup=$(mktemp)
  cp "$MISE_CONFIG" "$backup"
  restore_mise_config() {
    status=$?
    if [ "$status" -ne 0 ]; then
      cp "$backup" "$MISE_CONFIG"
      chezmoi apply "$MISE_TARGET" || true
    fi
    rm -f "$backup"
    exit "$status"
  }
  trap restore_mise_config EXIT INT TERM

  if confirm_update_mise_tools; then
    pin_mise_tools
  else
    mise exec -- chezmoi apply "$MISE_TARGET"
  fi
  mise_install
  mise exec -- sh "$0" update-rubygems
  mise exec -- sh "$0" install-language-packages
  prune_mise_installs

  rm -f "$backup"
  trap - EXIT INT TERM
}

prune_mise_installs() {
  mise ls | awk 'NF >= 2 && $0 !~ /[[:space:]](~|[A-Za-z]:)?[\\\/].*mise.*toml/ { print $1 "@" $2 }' | while IFS= read -r tool; do
    [ -n "$tool" ] && mise uninstall --yes "$tool"
  done
  mise prune --yes
  mise cache prune --yes
  mise reshim
}

mise_install() {
  mise install --yes
  mise upgrade --yes
  mise reshim
}

install_language_packages() {
  node_packages
  rust_packages
  ruby_packages
  go_packages
  uv_packages
}

mise_packages() {
  mise_install
  mise exec -- sh "$0" install-language-packages
}

clean_node_packages() (
  npm_cmd=$(command -v npm)
  tmp=$(mktemp -d)
  trap 'rm -rf "$tmp"' EXIT INT TERM
  awk 'NF && $1 !~ /^#/ { pkg=$1; if (pkg ~ /^@/) { n=split(pkg,a,"@"); if (n > 2) sub(/@[^@]*$/, "", pkg) } else sub(/@[^@]*$/, "", pkg); print pkg }' "$DOTFILES_DIR/install/npmfile" | sort -u >"$tmp/want"
  "$npm_cmd" list -g --depth=0 --json 2>/dev/null | node -e 'let s=""; process.stdin.on("data", d => s += d); process.stdin.on("end", () => { const j = s ? JSON.parse(s) : {}; Object.keys(j.dependencies || {}).forEach(p => console.log(p)); });' | sort -u >"$tmp/have"
  comm -23 "$tmp/have" "$tmp/want" | while IFS= read -r pkg; do
    [ -n "$pkg" ] && "$npm_cmd" uninstall -g "$pkg"
  done
)

clean_rust_packages() (
  tmp=$(mktemp -d)
  trap 'rm -rf "$tmp"' EXIT INT TERM
  wanted_packages "$DOTFILES_DIR/install/Rustfile" | sort -u >"$tmp/want"
  cargo install --list | awk '/^[^[:space:]].*:$/ { sub(/:.*/, "", $1); print $1 }' | sort -u >"$tmp/have"
  comm -23 "$tmp/have" "$tmp/want" | while IFS= read -r pkg; do
    [ -n "$pkg" ] && cargo uninstall "$pkg"
  done
)

clean_ruby_packages() {
  tmp=$(mktemp -d)
  trap 'rm -rf "$tmp"' EXIT INT TERM
  wanted_packages "$DOTFILES_DIR/install/Rubyfile" | while IFS= read -r gem; do
    ruby_wanted_gems "$gem"
  done | sort -u >"$tmp/want"
  ruby_protected_gems | sort -u >"$tmp/protected"
  gem list | tr -d '\r' | awk '/\(/ { print $1 }' | sort -u >"$tmp/have"
  comm -23 "$tmp/have" "$tmp/want" | comm -23 - "$tmp/protected" | sort -r | while IFS= read -r gem; do
    if [ -n "$gem" ]; then
      gem uninstall -a -x "$gem" 2>/dev/null || true
    fi
  done
}

clean_go_packages() (
  command -v go >/dev/null
  tmp=$(mktemp -d)
  trap 'rm -rf "$tmp"' EXIT INT TERM
  awk 'NF && $1 !~ /^#/ { n=split($1,a,"/"); if (a[n] ~ /^v[0-9]+$/ && n > 1) print a[n-1]; else print a[n] }' "$DOTFILES_DIR/install/Gofile" | sort -u >"$tmp/want"
  bin=$(go env GOBIN)
  [ -n "$bin" ] || bin="$(go env GOPATH)/bin"
  if [ -d "$bin" ]; then
    if is_windows; then
      find "$bin" -maxdepth 1 -type f -name '*.exe' -exec basename {} .exe \; | awk '$0 != "go" && $0 != "gofmt"' | sort -u >"$tmp/have"
    else
      find "$bin" -maxdepth 1 -type f -perm -111 -exec basename {} \; | awk '$0 != "go" && $0 != "gofmt"' | sort -u >"$tmp/have"
    fi
  else
    : >"$tmp/have"
  fi
  comm -23 "$tmp/have" "$tmp/want" | while IFS= read -r pkg; do
    [ -n "$pkg" ] && rm -f "$bin/$pkg" "$bin/$pkg.exe"
  done
)

clean_uv_packages() (
  tmp=$(mktemp -d)
  trap 'rm -rf "$tmp"' EXIT INT TERM
  wanted_packages "$DOTFILES_DIR/install/uv-file" | sort -u >"$tmp/want"
  uv tool list 2>/dev/null | awk '/^[[:alnum:]_][[:alnum:]_.-]* / { print $1 }' | sort -u >"$tmp/have"
  comm -23 "$tmp/have" "$tmp/want" | while IFS= read -r pkg; do
    [ -n "$pkg" ] && uv tool uninstall "$pkg"
  done
)

node_packages() {
  npm_cmd=$(command -v npm)
  clean_node_packages
  tmp=$(mktemp -d)
  trap 'rm -rf "$tmp"' EXIT INT TERM
  awk 'NF && $1 !~ /^#/ { spec=$1; pkg=spec; if (pkg ~ /^@/) { n=split(pkg,a,"@"); if (n > 2) sub(/@[^@]*$/, "", pkg) } else sub(/@[^@]*$/, "", pkg); print pkg " " spec }' "$DOTFILES_DIR/install/npmfile" | sort -u >"$tmp/want"
  "$npm_cmd" list -g --depth=0 --json 2>/dev/null | node -e 'let s=""; process.stdin.on("data", d => s += d); process.stdin.on("end", () => { const j = s ? JSON.parse(s) : {}; Object.keys(j.dependencies || {}).forEach(p => console.log(p)); });' | sort -u >"$tmp/have"
  while read -r pkg spec; do
    grep -qxF "$pkg" "$tmp/have" || "$npm_cmd" install -g "$spec"
  done <"$tmp/want"
  mise reshim
}

rust_packages() {
  require_rust_package_tools
  clean_rust_packages
  tmp=$(mktemp -d)
  trap 'rm -rf "$tmp"' EXIT INT TERM
  wanted_packages "$DOTFILES_DIR/install/Rustfile" | sort -u >"$tmp/want"
  cargo install --list | awk '/^[^[:space:]].*:$/ { sub(/:.*/, "", $1); print $1 }' | sort -u >"$tmp/have"
  comm -23 "$tmp/want" "$tmp/have" | while IFS= read -r pkg; do
    [ -n "$pkg" ] && cargo install "$pkg"
  done
  mise reshim
}

ruby_packages() {
  clean_ruby_packages
  tmp=$(mktemp -d)
  trap 'rm -rf "$tmp"' EXIT INT TERM
  wanted_packages "$DOTFILES_DIR/install/Rubyfile" | sort -u >"$tmp/want"
  ruby_protected_gems | sort -u >"$tmp/protected"
  gem list | tr -d '\r' | awk '/\(/ { print $1 }' | sort -u >"$tmp/have"
  comm -23 "$tmp/want" "$tmp/have" | comm -23 - "$tmp/protected" | while IFS= read -r gem; do
    [ -n "$gem" ] && gem install "$gem"
  done
  mise reshim
}

go_packages() {
  clean_go_packages
  bin=$(go env GOBIN)
  [ -n "$bin" ] || bin="$(go env GOPATH)/bin"
  wanted_packages "$DOTFILES_DIR/install/Gofile" | while IFS= read -r pkg; do
    name=$(printf '%s\n' "$pkg" | awk '{ n=split($1,a,"/"); if (a[n] ~ /^v[0-9]+$/ && n > 1) print a[n-1]; else print a[n] }')
    [ -x "$bin/$name" ] || [ -x "$bin/$name.exe" ] || go install "$pkg@latest"
  done
  mise reshim
}

uv_packages() {
  clean_uv_packages
  tmp=$(mktemp -d)
  trap 'rm -rf "$tmp"' EXIT INT TERM
  wanted_packages "$DOTFILES_DIR/install/uv-file" | sort -u >"$tmp/want"
  uv tool list 2>/dev/null | awk '/^[[:alnum:]_][[:alnum:]_.-]* / { print $1 }' | sort -u >"$tmp/have"
  comm -23 "$tmp/want" "$tmp/have" | while IFS= read -r pkg; do
    [ -n "$pkg" ] && uv tool install --force "$pkg"
  done
  mise reshim
}

case "${1:-}" in
mise-sync) mise_sync ;;
clean-mise-installs) prune_mise_installs ;;
mise-packages) mise_packages ;;
mise-install) mise_install ;;
install-language-packages) install_language_packages ;;
update-rubygems) update_rubygems ;;
node-packages) node_packages ;;
rust-packages) rust_packages ;;
ruby-packages) ruby_packages ;;
go-packages) go_packages ;;
uv-packages) uv_packages ;;
clean-node-packages) clean_node_packages ;;
clean-rust-packages) clean_rust_packages ;;
clean-ruby-packages) clean_ruby_packages ;;
clean-go-packages) clean_go_packages ;;
clean-uv-packages) clean_uv_packages ;;
*)
  printf '%s\n' "usage: $0 <package command>" >&2
  exit 2
  ;;
esac
