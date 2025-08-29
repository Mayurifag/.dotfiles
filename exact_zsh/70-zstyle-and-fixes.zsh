# Antidote plugins are now nicer to read
# https-COLON--SLASH--SLASH-github.com-SLASH-zsh-users-SLASH-zsh-autosuggestions becomes zsh-users__zsh-autosuggestions.
zstyle ':antidote:bundle' use-friendly-names 'yes'

# This speeds up pasting w/ autosuggest. Also fixes bug that I cant backspace after link with newlines after it
# https://github.com/zsh-users/zsh-autosuggestions/issues/238
pasteinit() {
  OLD_SELF_INSERT=${${(s.:.)widgets[self-insert]}[2,3]}
  zle -N self-insert url-quote-magic # I wonder if you'd need `.url-quote-magic`?
}

pastefinish() {
  zle -N self-insert $OLD_SELF_INSERT
}
zstyle :bracketed-paste-magic paste-init pasteinit
zstyle :bracketed-paste-magic paste-finish pastefinish

# https://github.com/zsh-users/zsh-autosuggestions/issues/351
ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(bracketed-paste)

# also https://github.com/LuckyWindsck/dotfiles/blob/c2319fead419a33a6cf197ff141d61b88ebabdff/.config/antidote/hooks/zsh-autosuggestions/plugin%3A%3Apost-hook.zsh

##################

# This prevents accidentally executing commands with extra newlines from pasting.
bracketed-paste() {
  # Perform the default paste action first.
  zle .$WIDGET
  # Then, remove any trailing whitespace characters from the entire buffer.
  # The '##' ensures that all trailing whitespace is greedily removed.
  BUFFER=${BUFFER%%[[:space:]]##}
  # Finally, remove any leading whitespace characters.
  BUFFER=${BUFFER##[[:space:]]##}
}
# Create the new custom widget.
zle -N bracketed-paste
