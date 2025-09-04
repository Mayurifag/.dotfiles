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

# Use Tab to accept autosuggestions. This overrides Tab's default
# completion behavior.
bindkey '\t' autosuggest-accept

# Use Right Arrow for completion at the end of a line, and for navigation otherwise.
smart-forward-or-complete() {
  # If the cursor is at the end of the line (RBUFFER is empty),
  # trigger completion. Otherwise, move forward one character.
  if [[ -z "$RBUFFER" ]]; then
    zle expand-or-complete
  else
    zle forward-char
  fi
}
zle -N smart-forward-or-complete

# The key sequence for Right Arrow can vary between terminals.
# '\e[C' is a common one.
bindkey '\e[C' smart-forward-or-complete
# Fallback for other terminals.
bindkey '^[[C' smart-forward-or-complete
