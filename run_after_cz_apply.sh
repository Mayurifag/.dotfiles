#!/bin/zsh

set -Eeuo pipefail

main() {
  local SOURCE_FILE="$HOME/Code/mpv-dark-box/dark-box.lua"
  local DEST_FILE="$HOME/.config/mpv/scripts/dark-box.lua"

  zsh -i -c "lnsf \"$SOURCE_FILE\" \"$DEST_FILE\""
  zsh -i -c "bundleantidote"
  zsh -i -c "stewbins"
}

main "$@"
