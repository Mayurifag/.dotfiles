safe_source $HOME/zsh/.zsh_plugins.sh

[[ -f /opt/homebrew/bin/brew ]] && _evalcache /opt/homebrew/bin/brew shellenv

safe_source "${HOMEBREW_PREFIX:-}"/opt/antidote/share/antidote/antidote.zsh
safe_source /usr/share/zsh-antidote/antidote.zsh
safe_source $HOME/.orbstack/shell/init.zsh
safe_source $HOME/.fzf.zsh

_evalcache mise activate zsh

if if_command_exists zoxide; then
  _evalcache zoxide init zsh
fi
