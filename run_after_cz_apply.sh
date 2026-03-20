#!/bin/sh

set -eu

main() {
  SOURCE_FILE="$HOME/Code/mpv-dark-box/dark-box.lua"
  DEST_FILE="$HOME/.config/mpv/scripts/dark-box.lua"

  zsh -i -c "lnsf \"$SOURCE_FILE\" \"$DEST_FILE\""
  zsh -i -c "bundleantidote"
}

main "$@"
