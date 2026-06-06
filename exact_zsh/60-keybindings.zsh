# Keybind features: Home/End/Delete fixes; Ctrl+Left/Right word movement;
# Ctrl+A selects the current command buffer; Backspace/Delete and typed text
# replace active selections; Shift+Arrow selects chars/lines; Shift+Ctrl+Arrow
# selects words; Esc clears selection; Tab accepts autosuggestions or completes;
# Up/Down search history by typed prefix.

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

if (( ${zle_highlight[(I)region:*]:-0} == 0 )); then
  zle_highlight+=(region:standout)
fi

# Ctrl+A selects the editable command buffer, not terminal scrollback. ZLE regions
# are separate from iTerm selections, so delete keys must explicitly consume them.
refresh-zle-region() {
  (( $+functions[_zsh_highlight] )) && _zsh_highlight
  zle -R
}

region-self-insert() {
  (( REGION_ACTIVE )) && delete-active-region
  zle .self-insert
}
zle -N self-insert region-self-insert

select-current-command() {
  MARK=0
  CURSOR=${#BUFFER}
  REGION_ACTIVE=1
  refresh-zle-region
}
zle -N select-current-command
bindkey '^A' select-current-command

delete-active-region() {
  local start=$MARK end=$CURSOR tmp
  (( start > end )) && { tmp=$start; start=$end; end=$tmp; }
  BUFFER="${BUFFER[1,$start]}${BUFFER[$(( end + 1 )),-1]}"
  CURSOR=$start
  REGION_ACTIVE=0
  refresh-zle-region
}

backward-delete-region-or-char() {
  if (( REGION_ACTIVE )); then
    delete-active-region
  else
    zle backward-delete-char
  fi
}
zle -N backward-delete-region-or-char
bindkey '^?' backward-delete-region-or-char

delete-region-or-char() {
  if (( REGION_ACTIVE )); then
    delete-active-region
  else
    zle delete-char
  fi
}
zle -N delete-region-or-char
bindkey '\e[3~' delete-region-or-char
bindkey '^[[3~' delete-region-or-char

kill-region-or-word() {
  if (( REGION_ACTIVE )); then
    delete-active-region
  else
    zle kill-word
  fi
}
zle -N kill-region-or-word
bindkey '\e[3;5~' kill-region-or-word
bindkey '^[[3;5~' kill-region-or-word

clear-active-region() {
  REGION_ACTIVE=0
  refresh-zle-region
}
zle -N clear-active-region
bindkey '^[' clear-active-region

select-left() {
  (( REGION_ACTIVE )) || MARK=$CURSOR
  REGION_ACTIVE=1
  (( CURSOR > 0 )) && (( CURSOR-- ))
  refresh-zle-region
}
zle -N select-left
bindkey '\e[1;2D' select-left
bindkey '^[[1;2D' select-left

select-right() {
  (( REGION_ACTIVE )) || MARK=$CURSOR
  REGION_ACTIVE=1
  (( CURSOR < ${#BUFFER} )) && (( CURSOR++ ))
  refresh-zle-region
}
zle -N select-right
bindkey '\e[1;2C' select-right
bindkey '^[[1;2C' select-right

select-word-left() {
  (( REGION_ACTIVE )) || MARK=$CURSOR
  zle backward-word
  REGION_ACTIVE=1
  refresh-zle-region
}
zle -N select-word-left
bindkey '\e[1;6D' select-word-left
bindkey '^[[1;6D' select-word-left

select-word-right() {
  (( REGION_ACTIVE )) || MARK=$CURSOR
  zle forward-word
  REGION_ACTIVE=1
  refresh-zle-region
}
zle -N select-word-right
bindkey '\e[1;6C' select-word-right
bindkey '^[[1;6C' select-word-right

select-up() {
  (( REGION_ACTIVE )) || MARK=$CURSOR
  REGION_ACTIVE=1
  zle up-line-or-history
  refresh-zle-region
}
zle -N select-up
bindkey '\e[1;2A' select-up
bindkey '^[[1;2A' select-up

select-down() {
  (( REGION_ACTIVE )) || MARK=$CURSOR
  REGION_ACTIVE=1
  zle down-line-or-history
  refresh-zle-region
}
zle -N select-down
bindkey '\e[1;2B' select-down
bindkey '^[[1;2B' select-down

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
