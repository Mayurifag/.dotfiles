#!/bin/sh
set -eu

script_dir=$(dirname "$0")
DOTFILES_DIR=${DOTFILES_DIR:-$(
  CDPATH=
  cd "$script_dir/.." && pwd
)}
MISE_CONFIG=${MISE_CONFIG:-$DOTFILES_DIR/dot_config/mise/config.toml.tmpl}
MISE_TARGET=${MISE_TARGET:-$HOME/.config/mise/config.toml}

wanted_packages() {
  awk 'NF && $1 !~ /^#/ { print $1 }' "$1"
}

ruby_protected_gems() {
  ruby -rrubygems -e 'puts Gem::Specification.select(&:default_gem?).map(&:name)'
}

pin_mise_tools() (
  tools=$(mktemp)
  trap 'rm -f "$tools"' EXIT INT TERM

  perl -ne 'next if /^\s*#/; print "$1\n" if /^\s*"?([^"=]+?)"?\s*=\s*"/' "$MISE_CONFIG" >"$tools"
  while IFS= read -r tool; do
    version=$(mise latest "$tool")
    MISE_TOOL="$tool" MISE_VERSION="$version" perl -0pi -e 'BEGIN { $tool=$ENV{MISE_TOOL}; $version=$ENV{MISE_VERSION}; } s/^(\s*"?\Q$tool\E"?\s*=\s*")[^"]+(")/$1$version$2/mg' "$MISE_CONFIG"
  done <"$tools"

  mise exec -- chezmoi apply "$MISE_TARGET"
)

mise_sync() {
  backup=$(mktemp)
  cp "$MISE_CONFIG" "$backup"
  restore_mise_config() {
    status=$?
    if [ "$status" -ne 0 ]; then
      cp "$backup" "$MISE_CONFIG"
      mise exec -- chezmoi apply "$MISE_TARGET" || true
    fi
    rm -f "$backup"
    exit "$status"
  }
  trap restore_mise_config EXIT INT TERM

  pin_mise_tools
  mise_install
  mise exec -- gem update --system
  mise exec -- sh "$0" install-language-packages
  prune_mise_installs

  rm -f "$backup"
  trap - EXIT INT TERM
}

prune_mise_installs() {
  mise ls | awk 'NF >= 2 && $0 !~ /[[:space:]](~|\/).*mise.*toml/ { print $1 "@" $2 }' | while IFS= read -r tool; do
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
  tmp=$(mktemp -d)
  trap 'rm -rf "$tmp"' EXIT INT TERM
  awk 'NF && $1 !~ /^#/ { pkg=$1; if (pkg ~ /^@/) { n=split(pkg,a,"@"); if (n > 2) sub(/@[^@]*$/, "", pkg) } else sub(/@[^@]*$/, "", pkg); print pkg }' "$DOTFILES_DIR/install/npmfile" | sort -u >"$tmp/want"
  npm list -g --depth=0 --json 2>/dev/null | node -e 'let s=""; process.stdin.on("data", d => s += d); process.stdin.on("end", () => { const j = s ? JSON.parse(s) : {}; Object.keys(j.dependencies || {}).sort().forEach(p => console.log(p)); });' >"$tmp/have"
  comm -23 "$tmp/have" "$tmp/want" | while IFS= read -r pkg; do
    [ -n "$pkg" ] && npm uninstall -g "$pkg"
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
  wanted_packages "$DOTFILES_DIR/install/Rubyfile" | sort -u >"$tmp/want"
  ruby_protected_gems | sort -u >"$tmp/protected"
  gem list | awk '/\(/ { print $1 }' | sort -u >"$tmp/have"
  comm -23 "$tmp/have" "$tmp/want" | comm -23 - "$tmp/protected" | sort -r | while IFS= read -r gem; do
    [ -n "$gem" ] && gem uninstall -a -x "$gem" 2>/dev/null || true
  done
  gem cleanup
}

clean_go_packages() (
  command -v go >/dev/null
  tmp=$(mktemp -d)
  trap 'rm -rf "$tmp"' EXIT INT TERM
  awk 'NF && $1 !~ /^#/ { n=split($1,a,"/"); if (a[n] ~ /^v[0-9]+$/ && n > 1) print a[n-1]; else print a[n] }' "$DOTFILES_DIR/install/Gofile" | sort -u >"$tmp/want"
  bin=$(go env GOBIN)
  [ -n "$bin" ] || bin="$(go env GOPATH)/bin"
  if [ -d "$bin" ]; then
    find "$bin" -maxdepth 1 -type f -perm -111 -exec basename {} \; | awk '$0 != "go" && $0 != "gofmt"' | sort -u >"$tmp/have"
  else
    : >"$tmp/have"
  fi
  comm -23 "$tmp/have" "$tmp/want" | while IFS= read -r pkg; do
    [ -n "$pkg" ] && rm -f "$bin/$pkg"
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
  clean_node_packages
  wanted_packages "$DOTFILES_DIR/install/npmfile" | xargs npm install -g
  mise reshim
}

rust_packages() {
  clean_rust_packages
  wanted_packages "$DOTFILES_DIR/install/Rustfile" | xargs cargo install --force
  mise reshim
}

ruby_packages() {
  clean_ruby_packages
  wanted_packages "$DOTFILES_DIR/install/Rubyfile" | xargs gem install
  mise reshim
}

go_packages() {
  clean_go_packages
  wanted_packages "$DOTFILES_DIR/install/Gofile" | while IFS= read -r pkg; do
    go install "$pkg@latest"
  done
  mise reshim
}

uv_packages() {
  clean_uv_packages
  wanted_packages "$DOTFILES_DIR/install/uv-file" | xargs -I {} uv tool install --reinstall {}
  mise reshim
}

case "${1:-}" in
mise-sync) mise_sync ;;
clean-mise-installs) prune_mise_installs ;;
mise-packages) mise_packages ;;
mise-install) mise_install ;;
install-language-packages) install_language_packages ;;
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
