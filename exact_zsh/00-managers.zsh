safe_source() {
  if [ -r "$1" ]; then
    source "$1"
  fi
}

[[ -f /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
for antidote_path in \
  "${HOMEBREW_PREFIX:-}/opt/antidote/share/antidote/antidote.zsh" \
  /usr/share/zsh-antidote/antidote.zsh \
  "$HOME/.local/share/antidote/antidote.zsh"
do
  if [[ -r "$antidote_path" ]]; then
    source "$antidote_path"
    break
  fi
done
