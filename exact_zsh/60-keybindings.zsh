# This file contains custom keybindings and settings to normalize behavior
# across different terminal emulators, especially for Konsole/Yakuake.

# --- Keybinding Fixes for Konsole/Yakuake ---
# It is NOT or just partly needed in MacOS because iTerm2 works for those usecases out of box.

# The following key sequences are what Konsole typically sends for these keys.
# We bind them to the correct Zsh Line Editor (ZLE) functions. This makes
# the command line behave as expected and often fixes issues inside other

# Fix the Home and End keys
# Binds '\e[1~' (Home) to `beginning-of-line`
bindkey '\e[1~' beginning-of-line
# Binds '\e[4~' (End) to `end-of-line`
bindkey '\e[4~' end-of-line

# Fix the Delete key
# Binds '\e[3~' (Delete) to `delete-char` (deletes character under the cursor)
bindkey '\e[3~' delete-char

# Fix Ctrl + Left/Right Arrow for word-wise movement
bindkey '\e[1;5D' backward-word
bindkey '\e[1;5C' forward-word

# This is a fallback for other terminals that might send different codes.
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word

# --- Swap Tab and Right Arrow for autosuggestions and completions ---

# Use Tab to accept autosuggestions if one is available, otherwise fall back to completion.
smart-tab-accept-or-complete() {
  if [[ -n "${ZSH_AUTOSUGGEST_SUGGESTION-}" ]]; then
    zle autosuggest-accept
  else
    zle expand-or-complete
  fi
}
zle -N smart-tab-accept-or-complete
bindkey '\t' smart-tab-accept-or-complete

# --- Multiline history navigation ---
# Fixes issue where Up Arrow jumps to history instead of moving cursor up in multiline command
# NOT SURE IF IT WORKS

autoload -Uz up-line-or-beginning-search
autoload -Uz down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search
# Also bind standard terminfo keys if available (covers other terminal modes)
if [[ -n "${terminfo[kcuu1]}" ]]; then
  bindkey "${terminfo[kcuu1]}" up-line-or-beginning-search
fi
if [[ -n "${terminfo[kcud1]}" ]]; then
  bindkey "${terminfo[kcud1]}" down-line-or-beginning-search
fi
# ---
