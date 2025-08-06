# This file contains custom keybindings and settings to normalize behavior
# across different terminal emulators, especially for Konsole/Yakuake.

# --- Keybinding Fixes for Konsole/Yakuake ---
# It is NOT needed in MacOS because iTerm2 works for those usecases out of box.
# Yet still I will need to check.

# The following key sequences are what Konsole typically sends for these keys.
# We bind them to the correct Zsh Line Editor (ZLE) functions. This makes
# the command line behave as expected and often fixes issues inside other

# applications like `vi` or `nano` that use the shell's environment.

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


# --- Paste Behavior ---

# Trim trailing whitespace from pasted text.
# Zsh's "bracketed paste" mode wraps pasted text in special markers.
# We intercept this to clean up the text before it's inserted.
_trim_trailing_ws_on_paste() {
  local -a P_paste
  P_paste=("${(@f)P_paste}")
  if [[ -n "${P_paste[-1]}" ]]; then
    P_paste[-1]="${P_paste[-1]%%[[:space:]]##}"
  fi
}

# Create a custom ZLE widget that calls our trimming function
# before calling the original paste handler.
_custom_paste_handler() {
  _trim_trailing_ws_on_paste
  zle .paste
}

# Register our custom handler to override the default bracketed paste.
zle -N zle-bracketed-paste _custom_paste_handler
