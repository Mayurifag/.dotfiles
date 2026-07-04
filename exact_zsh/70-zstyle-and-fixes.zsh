# Antidote plugins are now nicer to read
# https-COLON--SLASH--SLASH-github.com-SLASH-zsh-users-SLASH-zsh-autosuggestions becomes zsh-users__zsh-autosuggestions.
zstyle ':antidote:bundle' use-friendly-names 'yes'

# This speeds up pasting w/ autosuggest. Also fixes bug that I cant backspace after link with newlines after it
# https://github.com/zsh-users/zsh-autosuggestions/issues/238
pasteinit() {
  OLD_SELF_INSERT=${${(s.:.)widgets["self-insert"]}[2,3]}
  zle -N self-insert url-quote-magic
}

pastefinish() {
  [[ -n ${OLD_SELF_INSERT:-} ]] && zle -N self-insert $OLD_SELF_INSERT

  # Avoid accidental execution from copied commands with surrounding newlines.
  BUFFER=${BUFFER%%[[:space:]]##}
  BUFFER=${BUFFER##[[:space:]]##}
}
zstyle :bracketed-paste-magic paste-init pasteinit
zstyle :bracketed-paste-magic paste-finish pastefinish

# https://github.com/zsh-users/zsh-autosuggestions/issues/351
ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(bracketed-paste)

# also https://github.com/LuckyWindsck/dotfiles/blob/c2319fead419a33a6cf197ff141d61b88ebabdff/.config/antidote/hooks/zsh-autosuggestions/plugin%3A%3Apost-hook.zsh

autoload -Uz bracketed-paste-magic
zle -N bracketed-paste bracketed-paste-magic
