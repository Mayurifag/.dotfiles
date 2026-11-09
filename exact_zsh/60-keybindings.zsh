# Keybind features: Home/End/Delete fixes; Ctrl+Left/Right word movement;
# Ctrl+A selects the current command buffer; Backspace/Delete and typed text
# replace active selections; Shift+Arrow selects chars/lines; Shift+Ctrl+Arrow
# selects words; Esc clears selection; Tab accepts autosuggestions or completes;
# Up/Down search history by typed prefix.

# --- Zsh prompt key bindings ---

# Fix the Home and End keys in normal and application cursor modes.
bindkey '\e[1~' beginning-of-line
bindkey '\e[H' beginning-of-line
bindkey '\eOH' beginning-of-line
bindkey '\e[4~' end-of-line
bindkey '\e[F' end-of-line
bindkey '\eOF' end-of-line

# Consume unused special keys instead of inserting their escape sequences.
ignore-unused-key() { :; }
zle -N ignore-unused-key
() {
  local key cap
  local -a keys=( $'\e[2~' $'\e[5~' $'\e[6~' )

  if zmodload -i zsh/terminfo; then
    [[ -n ${terminfo[khome]} ]] && bindkey "${terminfo[khome]}" beginning-of-line
    [[ -n ${terminfo[kend]} ]] && bindkey "${terminfo[kend]}" end-of-line
    for cap in kich1 kpp knp kf{1..63}; do
      [[ -n ${terminfo[$cap]} ]] && keys+=("${terminfo[$cap]}")
    done
  fi

  for key in "${keys[@]}"; do
    if [[ $(bindkey "$key") == *' undefined-key' ]]; then
      bindkey "$key" ignore-unused-key
    fi
  done
}

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
ZSH_AUTOSUGGEST_IGNORE_WIDGETS+=(smart-tab-accept-or-complete)
smart-tab-accept-or-complete() {
  if [[ -n "${POSTDISPLAY-}" && $CURSOR -eq ${#BUFFER} ]]; then
    zle autosuggest-accept
  elif zle -l fzf-completion >/dev/null 2>&1; then
    zle fzf-completion
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
