source ~/.private_exports
source /usr/share/zsh/share/antigen.zsh

antigen use oh-my-zsh

antigen bundle gem
antigen bundle git
antigen bundle docker
antigen bundle capistrano
antigen bundle bundler
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zsh-users/zsh-completions src
antigen bundle archlinux
antigen bundle sudo

antigen theme candy

# Tell Antigen that you're done.
antigen apply

setopt AUTOCD
setopt COMPLETE_ALIASES

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# allow functions to have local options
setopt LOCAL_OPTIONS
# allow functions to have local traps
setopt LOCAL_TRAPS
# share history between sessions ???
setopt SHARE_HISTORY
# adds history
setopt APPEND_HISTORY
# adds history incrementally and share it across sessions
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
# don't record dupes in history
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY
setopt HIST_EXPIRE_DUPS_FIRST

zstyle ':completion:*' rehash true

start() {
  sudo systemctl start $1.service
}
restart() {
  sudo systemctl restart $1.service
}
stop() {
  sudo systemctl stop $1.service
}
enable() {
  sudo systemctl enable $1.service
}
status() {
  sudo systemctl status $1.service
}
disable() {
  sudo systemctl disable $1.service
}

alias docker='sudo docker'
alias docker_delete_exited='docker rm $(docker ps -a -q -f status=exited)'
alias grep='grep --color'
alias less="LESS='-RS#3NM~g' less"
alias rc='rails console'

# Create a new directory and enter it
function mk() {
  mkdir -p "$@" && cd "$@"
}

export EDITOR='nano'
export VISUAL='atom'
export BROWSER='firefox'
export NVM_LAZY_LOAD=true
export ZSH_AUTOSUGGEST_USE_ASYNC=1

# Go
export PATH="$PATH:$HOME/go/bin"

# Rbenv
# export PATH="$HOME/.rbenv/bin:$PATH"

eval "$(rbenv init -)"
