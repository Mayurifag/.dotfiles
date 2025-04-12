# Ripgrep
if type rg &> /dev/null; then
  export FZF_DEFAULT_COMMAND='rg --files --hidden'
  export FZF_DEFAULT_OPTS='-m --height 50% --border'
fi


### Go ###
# export GOPATH="$HOME/go"
# export PATH="$PATH:$GOPATH/bin"

## Rust / cargo
export PATH=$PATH:$HOME/.cargo/bin

# System
export LC_ALL=en_US.UTF-8
export VISUAL=cursor
export EDITOR=vi
export SUDO_EDITOR=vi

# Homebrew
export HOMEBREW_CASK_OPTS="--no-quarantine"

# Zsh
export DISABLE_UNTRACKED_FILES_DIRTY="true"
export DISABLE_AUTO_UPDATE="true"

# export KEYTIMEOUT=1 # Shorter delay typing https://www.johnhawthorn.com/2012/09/vi-escape-delays/

export PATH="$HOME/.local/bin:$PATH"
