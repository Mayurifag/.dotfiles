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
