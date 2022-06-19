# fnm
eval "$(fnm env --use-on-cd)"

# frum
eval "$(frum init)"

# Ripgrep
if type rg &> /dev/null; then
  export FZF_DEFAULT_COMMAND='rg --files --hidden'
  export FZF_DEFAULT_OPTS='-m --height 50% --border'
fi


### Go ###
export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin"

## Rust / cargo
export PATH=$PATH:$HOME/.cargo/bin

## OCaml / opam
export PATH=$PATH:$HOME/.opam/default/bin

# System
export LC_ALL=en_US.UTF-8
# export LANG=ru_RU.UTF8
# export LC_COLLATE=ru_RU.UTF-8
# export LC_CTYPE=ru_RU.UTF-8
export VISUAL=code
export EDITOR=vi
export SUDO_EDITOR=vi

# export BAT_PAGER="less -RF"

# Zsh
# export KEYTIMEOUT=1 # Shorter delay typing https://www.johnhawthorn.com/2012/09/vi-escape-delays/
export DISABLE_UNTRACKED_FILES_DIRTY="true"
export DISABLE_AUTO_UPDATE="true"
