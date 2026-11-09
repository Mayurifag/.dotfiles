#!/bin/sh
set -eu

script_dir=$(dirname "$0")
DOTFILES_DIR=${DOTFILES_DIR:-$(
  CDPATH=
  cd "$script_dir/.." && pwd
)}
MISE_CONFIG=${MISE_CONFIG:-$DOTFILES_DIR/dot_config/mise/config.toml.tmpl}
MISE_TARGET=${MISE_TARGET:-$HOME/.config/mise/config.toml}
MISE_RUNTIME_TOOLS=${MISE_RUNTIME_TOOLS:-"node go python rust ruby"}

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
    printf 'error: required command not found in PATH: %s\n' "$1" >&2
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

is_mise_runtime_tool() {
  for runtime_tool in $MISE_RUNTIME_TOOLS; do
    [ "$1" = "$runtime_tool" ] && return 0
  done
  return 1
}

mise_tools_in_file() {
  perl -ne 'if (/^\s*\[tools\]\s*$/) { $tools=1; next } if (/^\s*\[[A-Za-z0-9_.-]/) { $tools=0 } next unless $tools; next if /^\s*#/; print "$1 $2\n" if /^\s*"?([^"=]+?)"?\s*=\s*(?:\{\s*version\s*=\s*)?"([^"]+)"/' "$1"
}

mise_config_tools() {
  mise_tools_in_file "$MISE_CONFIG"
}

mise_target_tools() {
  mise_tools_in_file "$MISE_TARGET"
}

ruby_protected_gems() {
  ruby -rrubygems -e 'names = Gem::Specification.select(&:default_gem?).map(&:name); begin; require "bundled_gems"; names += Gem::BUNDLED_GEMS.const_defined?(:SINCE) ? Gem::BUNDLED_GEMS::SINCE.keys : []; names += Gem::BUNDLED_GEMS.const_defined?(:EXACT) ? Gem::BUNDLED_GEMS::EXACT.values : []; names += Gem::BUNDLED_GEMS.const_defined?(:PREFIXED) ? Gem::BUNDLED_GEMS::PREFIXED.keys : []; rescue LoadError; end; names += %w[debug matrix minitest net-ftp net-imap net-pop net-smtp power_assert prime rake rbs readline repl_type_completor rexml rss rubygems-update test-unit typeprof]; puts names.uniq' | tr -d '\r'
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

  mise_config_tools >"$tools"
  pin_mise_tool_file "$tools"

  chezmoi apply "$MISE_TARGET"
)

pin_mise_tool_file() {
  tools=$1
  while read -r tool current; do
    latest_tool=$tool
    if [ "$tool" = ruby ]; then
      case "$current" in
      truffleruby-[0-9]*.*) latest_tool="ruby@$(printf '%s\n' "$current" | awk -F. '{ print $1 }')" ;;
      truffleruby+graalvm-[0-9]*.*) latest_tool="ruby@$(printf '%s\n' "$current" | awk -F. '{ print $1 }')" ;;
      esac
    fi
    version=$(mise latest "$latest_tool")
    MISE_TOOL="$tool" MISE_CURRENT="$current" MISE_VERSION="$version" perl -0pi -e 'BEGIN { $tool=$ENV{MISE_TOOL}; $current=$ENV{MISE_CURRENT}; $version=$ENV{MISE_VERSION}; } s/^(\s*"?\Q$tool\E"?\s*=\s*(?:\{\s*version\s*=\s*)?")\Q$current\E(")/$1$version$2/mg' "$MISE_CONFIG"
  done <"$tools"
}

mise_sync() (
  sync_mode=${1:-all}
  sync_tmp=$(mktemp -d)
  backup=$sync_tmp/config
  cp "$MISE_CONFIG" "$backup"
  restore_mise_config() {
    status=$?
    if [ "$status" -ne 0 ]; then
      cp "$backup" "$MISE_CONFIG"
      chezmoi apply "$MISE_TARGET" || true
    fi
    rm -rf "$sync_tmp"
    exit "$status"
  }
  trap restore_mise_config EXIT INT TERM

  if [ "$sync_mode" = all ]; then
    if confirm_update_mise_tools; then
      pin_mise_tools
    else
      mise exec -- chezmoi apply "$MISE_TARGET"
    fi
    winget_packages
    mise_install
    mise exec -- sh "$0" update-rubygems
    mise exec -- sh "$0" install-language-packages
    prune_mise_installs
  else
    tools=$sync_tmp/tools
    chezmoi apply "$MISE_TARGET"
    mise_target_tools | while read -r tool version; do
      [ -n "$version" ] || continue
      is_mise_runtime_tool "$tool" || printf '%s %s\n' "$tool" "$version"
    done >"$tools"
    pin_mise_tool_file "$tools"
    chezmoi apply "$MISE_TARGET"
    while read -r tool version; do
      [ -n "$version" ] || continue
      mise install --yes "$tool"
    done <"$tools"
    mise reshim
  fi
)

prune_mise_installs() {
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
  for manager in node rust ruby go uv; do
    reconcile_packages "$manager"
  done
}

mise_packages() {
  mise_install
  mise exec -- sh "$0" install-language-packages
}

node_inventory() {
  npm_cmd=$(command -v npm)
  awk 'NF && $1 !~ /^#/ { spec=$1; pkg=spec; if (pkg ~ /^@/) { n=split(pkg,a,"@"); if (n > 2) sub(/@[^@]*$/, "", pkg) } else sub(/@[^@]*$/, "", pkg); print pkg " " spec }' "$DOTFILES_DIR/install/npmfile" | sort -u >"$tmp/want-specs"
  awk '{ print $1 }' "$tmp/want-specs" | sort -u >"$tmp/want"
  "$npm_cmd" list -g --depth=0 --json 2>/dev/null | node -e 'let s=""; process.stdin.on("data", d => s += d); process.stdin.on("end", () => { const j = s ? JSON.parse(s) : {}; Object.entries(j.dependencies || {}).forEach(([p, d]) => console.log(p + " " + d.version)); });' | sort -u >"$tmp/installed"
  awk '{ print $1 }' "$tmp/installed" >"$tmp/have"
}

rust_inventory() {
  [ "$mode" = clean ] || require_rust_package_tools
  wanted_packages "$DOTFILES_DIR/install/Rustfile" | sort -u >"$tmp/want"
  cargo install --list | awk '/^[^[:space:]].*:$/ { sub(/:.*/, "", $1); print $1 }' | sort -u >"$tmp/have"
}

ruby_inventory() {
  wanted_packages "$DOTFILES_DIR/install/Rubyfile" | while IFS= read -r gem; do
    ruby_wanted_gems "$gem"
  done | sort -u >"$tmp/want"
  ruby_protected_gems | sort -u >"$tmp/protected"
  gem list | tr -d '\r' | awk '/\(/ { print $1 }' | sort -u >"$tmp/have"
  comm -23 "$tmp/have" "$tmp/want" | comm -23 - "$tmp/protected" | sort -r >"$tmp/remove"
  # Keep dependency closure for pruning, but only install explicitly requested gems.
  wanted_packages "$DOTFILES_DIR/install/Rubyfile" | sort -u >"$tmp/requested"
}

go_inventory() {
  command -v go >/dev/null
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
}

uv_inventory() {
  uv_package_names <"$DOTFILES_DIR/install/uv-file" | sort -u >"$tmp/want"
  uv tool list >"$tmp/list"
  awk '/^[[:alnum:]_][[:alnum:]_.-]* / { print $1 }' "$tmp/list" | sort -u >"$tmp/have"
}

uv_package_names() {
  awk 'NF && $1 !~ /^#/ { pkg=$1; sub(/\[.*/, "", pkg); sub(/[<>=!~@].*/, "", pkg); gsub(/[-_.]+/, "-", pkg); print tolower(pkg) }'
}

winget_packages() {
  is_windows || return 0
  require_command winget
  wanted_packages "$DOTFILES_DIR/install/Wingetfile" | while IFS= read -r package; do
    winget list --id "$package" --exact --accept-source-agreements --disable-interactivity >/dev/null 2>&1 || winget install --id "$package" --exact --silent --disable-interactivity --accept-package-agreements --accept-source-agreements
  done
}

node_install() {
  while read -r pkg spec; do
    if printf '%s\n' "${spec#"$pkg"@}" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?(\+[0-9A-Za-z.-]+)?$'; then
      grep -qxF "$pkg ${spec#"$pkg"@}" "$tmp/installed" || "$npm_cmd" install -g "$spec"
    else
      grep -qxF "$pkg" "$tmp/have" || "$npm_cmd" install -g "$spec"
    fi
  done <"$tmp/want-specs"
}

rust_install() {
  comm -23 "$tmp/want" "$tmp/have" | while IFS= read -r pkg; do
    [ -n "$pkg" ] && cargo install "$pkg"
  done
}

ruby_install() {
  comm -23 "$tmp/requested" "$tmp/have" | comm -23 - "$tmp/protected" | while IFS= read -r gem; do
    [ -n "$gem" ] && gem install "$gem"
  done
}

go_install() {
  wanted_packages "$DOTFILES_DIR/install/Gofile" | while IFS= read -r pkg; do
    name=$(printf '%s\n' "$pkg" | awk '{ n=split($1,a,"/"); if (a[n] ~ /^v[0-9]+$/ && n > 1) print a[n-1]; else print a[n] }')
    [ -x "$bin/$name" ] || [ -x "$bin/$name.exe" ] || go install "$pkg@latest"
  done
}

uv_install() {
  awk 'NF && $1 !~ /^#/ { print }' "$DOTFILES_DIR/install/uv-file" | while IFS= read -r spec; do
    pkg=$(printf '%s\n' "$spec" | uv_package_names)
    if grep -qxF "$pkg" "$tmp/have"; then
      printf '%s\n' "$spec" | xargs uv tool install
    else
      printf '%s\n' "$spec" | xargs uv tool install --force
    fi
  done
}

node_remove() { "$npm_cmd" uninstall -g "$1"; }
rust_remove() { cargo uninstall "$1"; }
ruby_remove() { gem uninstall -a -x "$1" 2>/dev/null || true; }
go_remove() { rm -f "$bin/$1" "$bin/$1.exe"; }
uv_remove() { uv tool uninstall "$1"; }

reconcile_packages() (
  manager=$1
  mode=${2:-install}
  tmp=$(mktemp -d)
  trap 'rm -rf "$tmp"' EXIT INT TERM
  "${manager}_inventory"
  [ -f "$tmp/remove" ] || comm -23 "$tmp/have" "$tmp/want" >"$tmp/remove"
  while IFS= read -r pkg; do
    [ -n "$pkg" ] && "${manager}_remove" "$pkg"
  done <"$tmp/remove"
  if [ "$mode" = install ]; then
    "${manager}_install"
    mise reshim
  fi
)

case "${1:-}" in
mise-sync) mise_sync ;;
mise-sync-only-software) mise_sync software ;;
clean-mise-installs) prune_mise_installs ;;
mise-packages) mise_packages ;;
mise-install) mise_install ;;
winget-packages) winget_packages ;;
install-language-packages) install_language_packages ;;
update-rubygems) update_rubygems ;;
node-packages | rust-packages | ruby-packages | go-packages | uv-packages) reconcile_packages "${1%-packages}" ;;
clean-node-packages | clean-rust-packages | clean-ruby-packages | clean-go-packages | clean-uv-packages)
  manager=${1#clean-}
  reconcile_packages "${manager%-packages}" clean
  ;;
*)
  printf '%s\n' "usage: $0 <package command>" >&2
  exit 2
  ;;
esac
