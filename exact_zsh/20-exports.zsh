# Ripgrep
if type rg &> /dev/null; then
  export FZF_DEFAULT_COMMAND='rg --files --hidden'
  export FZF_DEFAULT_OPTS='-m --height 50% --border'
fi

# System
export LC_ALL=en_US.UTF-8
export VISUAL=code
export EDITOR=vim
export SUDO_EDITOR=vim

# Homebrew
export HOMEBREW_CASK_OPTS="--no-quarantine"
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_ENV_HINTS=1

# Zsh
export DISABLE_UNTRACKED_FILES_DIRTY="true"
export DISABLE_AUTO_UPDATE="true"
export KEYTIMEOUT=1 # Shorter delay typing https://www.johnhawthorn.com/2012/09/vi-escape-delays/

# History
export HISTFILE=~/.zsh_history # Where to save history to disk

# if you use any of the HIST_*_DUPS options, you should make sure $HISTSIZE is
# always at least 20% bigger than $SAVEHIST. Otherwise, Zsh is not able to
# effectively eliminate duplicates once your history exceeds $SAVEHIST
export HISTSIZE=8000 # Lines of history to keep in memory for current session
export SAVEHIST=5000 # Number of commands to save in the file

# Paths

# Function to safely append to PATH only if directory exists
safe_append_to_path() {
  if [[ -d "$1" ]]; then
    export PATH="$PATH:$1"
  fi
}

safe_append_to_path "$HOME/.lmstudio/bin" # LM Studio CLI
safe_append_to_path "$HOME/.cargo/bin" # Rust/cargo
safe_append_to_path "$HOME/.local/bin" # Local binaries I use or install

### Go ###
# export GOPATH="$HOME/go"
# safe_append_to_path "$GOPATH/bin"

# Plugin Configurations
# ---------------------

# There was a problem with pasted text with following whitespaces resulting that
# I can't use backspace or left arrow to navigate, etc.

# This speeds up pasting w/ autosuggest
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

# Antidote plugins are now nicer to read
# https-COLON--SLASH--SLASH-github.com-SLASH-zsh-users-SLASH-zsh-autosuggestions becomes zsh-users__zsh-autosuggestions.
zstyle ':antidote:bundle' use-friendly-names 'yes'
