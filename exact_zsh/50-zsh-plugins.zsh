# Those bundled already via bundleantidote on cz apply
safe_source "$HOME/zsh/.zsh_plugins.sh"

if (($+commands[fzf])); then
  source <(fzf --zsh)
fi
