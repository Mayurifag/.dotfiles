# Ripgrep
if type rg &> /dev/null; then
  export FZF_DEFAULT_COMMAND='rg --files --hidden'
  export FZF_DEFAULT_OPTS='-m --height 50% --border'
fi

# System
export LC_ALL=en_US.UTF-8
export VISUAL=code
export EDITOR=vi
export SUDO_EDITOR=vi

# Homebrew
export HOMEBREW_CASK_OPTS="--no-quarantine"
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_ENV_HINTS=1

# Zsh
export DISABLE_UNTRACKED_FILES_DIRTY="true"
export DISABLE_AUTO_UPDATE="true"
export KEYTIMEOUT=1 # Shorter delay typing https://www.johnhawthorn.com/2012/09/vi-escape-delays/

# History
export HISTSIZE=10240 # Lines of history to keep in memory for current session
export HISTFILESIZE=10240 # Number of commands to save in the file
export HISTFILE=~/.zsh_history # Where to save history to disk

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
