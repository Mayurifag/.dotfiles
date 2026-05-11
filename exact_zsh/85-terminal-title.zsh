typeset -g _terminal_title_git="${commands[git]:-}"
typeset -g _terminal_title_last_pwd=""
typeset -g _terminal_title_last_title=""
typeset -gA _terminal_title_repo_names

_terminal_title_cwd() {
  local title git_root remote_url repo_name
  local -a remotes

  if [[ "$PWD" == "$_terminal_title_last_pwd" ]]; then
    title="$_terminal_title_last_title"
  else
    title="$PWD"
    if [[ -n "$_terminal_title_git" ]] && git_root=$("$_terminal_title_git" -C "$PWD" rev-parse --show-toplevel 2>/dev/null); then
      if ((${+_terminal_title_repo_names[$git_root]})); then
        repo_name="$_terminal_title_repo_names[$git_root]"
      else
        remotes=("${(@f)$("$_terminal_title_git" -C "$git_root" remote 2>/dev/null)}")
        repo_name=""
        if ((${#remotes[@]} == 1)) && [[ "${remotes[1]}" == "origin" ]]; then
          remote_url="$("$_terminal_title_git" -C "$git_root" remote get-url origin 2>/dev/null)"
          remote_url="${remote_url%/}"
          repo_name="${remote_url:t}"
          repo_name="${repo_name%.git}"
        fi
        _terminal_title_repo_names[$git_root]="$repo_name"
      fi
      if [[ -n "$repo_name" ]]; then
        title="$repo_name"
      fi
    fi

    if [[ "$title" == "$PWD" && ("$title" == "$HOME" || "$title" == "$HOME/"*) ]]; then
      title="~${title#$HOME}"
    fi

    _terminal_title_last_pwd="$PWD"
    _terminal_title_last_title="$title"
  fi

  printf '\033]0;%s\007\033]1;%s\007\033]2;%s\007' "$title" "$title" "$title"
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _terminal_title_cwd
