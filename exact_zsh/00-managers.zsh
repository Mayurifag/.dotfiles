[[ -f /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
safe_source "${HOMEBREW_PREFIX:-}"/opt/antidote/share/antidote/antidote.zsh
safe_source /usr/share/zsh-antidote/antidote.zsh
