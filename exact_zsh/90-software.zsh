safe_source $HOME/.orbstack/shell/init.zsh

if if_command_exists zoxide; then
  eval "$(zoxide init zsh)"
fi
