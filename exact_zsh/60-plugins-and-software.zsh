safe_source $HOME/zsh/.zsh_plugins.sh
safe_source $HOME/.orbstack/shell/init.zsh
safe_source $HOME/.fzf.zsh

if if_command_exists zoxide; then
  eval "$(zoxide init zsh)"
fi
