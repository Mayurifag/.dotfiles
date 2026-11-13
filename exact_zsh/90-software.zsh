safe_source $HOME/.orbstack/shell/init.zsh

if if_command_exists zoxide; then
  eval "$(zoxide init zsh)"

  _zoxide_cd_completion() {
    # Keep normal directory completion before zoxide's ranked matches.
    _cd && return 0
    (( CURRENT == 2 && ${#words} == 2 )) || return 1

    local matches query=${(Q)PREFIX}
    [[ -n $query && $query != -* && -z $SUFFIX ]] || return 1
    matches=$(command zoxide query --list --exclude "$(__zoxide_pwd)" -- "$query" 2>/dev/null)
    [[ -n $matches ]] || return 1
    local -a directories=("${(@f)matches}")
    compadd -U -V zoxide -S '' -- "${directories[@]}" || return 1
    (( ${#directories} > 1 )) && compstate[insert]=menu
    return 0
  }
  compdef _zoxide_cd_completion cd
fi
