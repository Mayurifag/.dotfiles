#!/bin/zsh
. $HOME/.zshrc

SOURCE_FILE="$HOME/Code/mpv-dark-box/dark-box.lua"
DEST_FILE="$HOME/.config/mpv/scripts/dark-box.lua"

if [[ -f "$SOURCE_FILE" ]]; then
  ln -sf "$SOURCE_FILE" "$DEST_FILE"
elif [[ -L "$DEST_FILE" && ! -e "$DEST_FILE" ]]; then
  # If the source is missing, remove a broken link if it exists
  rm -f "$DEST_FILE"
fi

bundleantidote
. $HOME/.zshrc
