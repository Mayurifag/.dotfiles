
# On slow systems, checking the cached .zcompdump file to see if it must be
# regenerated adds a noticable delay to zsh startup.  This little hack restricts
# it to once a day.  It should be pasted into your own completion file.
#
# The globbing is a little complicated here:
# - '#q' is an explicit glob qualifier that makes globbing work within zsh's [[ ]] construct.
# - 'N' makes the glob pattern evaluate to nothing when it doesn't match (rather than throw a globbing error)
# - '.' matches "regular files"
# - 'mh+24' matches files (or directories or whatever) that are older than 24 hours.
autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
	compinit;
else
	compinit -C;
fi;

# You may need to manually set your language environment
export LC_ALL=en_US.UTF-8
export LANG=ru_RU.UTF8

export VISUAL=code
export EDITOR=nano
export SUDO_EDITOR=nano
export QT_QPA_PLATFORMTHEME=qt5ct

export KEYTIMEOUT=1 # Shorter delay typing

setopt hash_list_all            # hash everything before completion
setopt completealiases          # complete alisases
setopt always_to_end            # when completing from the middle of a word, move the cursor to the end of the word
setopt complete_in_word         # allow completion from within a word/phrase
setopt list_ambiguous           # complete as much of a completion until it gets ambiguous.
setopt auto_remove_slash        # self explicit
setopt chase_links              # resolve symlinks

# History
HISTSIZE=10000 # Lines of history to keep in memory for current session
HISTFILESIZE=10000 # Number of commands to save in the file
SAVEHIST=10000 # Number of history entries to save to disk
HISTFILE=~/.zsh_history # Where to save history to disk
HISTDUP=erase # Erase duplicates in the history file
setopt hist_ignore_dups # Ignore duplicates

# Options - `man zshoptions`
setopt append_history # Append history to the history file (no overwriting)
setopt share_history # Share history across terminals
setopt inc_append_history # Immediately append to the history file, not just when a term is killed
setopt extended_glob # Use extended globbing syntax
setopt auto_cd # Auto change to a dir without typing cd

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

DISABLE_AUTO_UPDATE="true"

# Update Zsh plugins
uz(){
  antibody bundle <~/.dotfiles/zsh/plugins.txt >~/.zsh_plugins.sh
  antibody update
}

source ~/.zsh_plugins.sh # Load zsh plugins

alias ls='ls --color=auto'
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias ..='cd ..'
alias df='df -h'
alias diff='colordiff'              # requires colordiff package
alias du='du -c -h'
alias free='free -m'                # show sizes in MB
alias grep='grep --color=auto'
alias mkdir='mkdir -p -v'
alias more='less'
alias nano='nano -w'
alias scat='sudo cat'
alias root='sudo su'
alias e='nano'
alias se='sudo nano'
alias rs='bundle exec rails server'
alias rc='bundle exec rails console'
alias dbc='bundle exec rails dbconsole'
alias reboot='sudo reboot'
alias ll='ls -alh'
alias net="ping ya.ru | grep -E --only-match --color=never '[0-9\.]+ ms'" # check connection
alias hs='history | grep'
alias myip="curl http://ipecho.net/plain; echo"
alias u="yay -Syu"
alias dcp='docker-compose'
alias grom='git rebase -i origin/master'
alias bi='bundle install'
alias bu='bundle update'

# https://stackoverflow.com/questions/6089294/why-do-i-need-to-do-set-upstream-all-the-time
alias gp='[[ -z $(git config "branch.$(git symbolic-ref --short HEAD).merge") ]] && git push -u origin $(git symbolic-ref --short HEAD) || git push'
alias gpf='git push --force'
alias q='git add . && git commit -m "WIP: $(curl -s https://whatthecommit.com/index.txt)" && git push origin HEAD'
alias vboost='pamixer --allow-boost --set-volume 150'
alias f='code .'
alias v='code'
alias config='code ~/.zshrc'
alias dbeaver='GTK_THEME=adwaita dbeaver'
alias tdl='tail -f ./log/development.log'
alias ttl='tail -f ./log/test.log'

prg() {
  git pull -a > /dev/null

  local branches=$(git branch --merged | grep -v 'develop' | grep -v 'master' | grep -v 'qa' | sed 's/^\s*//')
  branches=(${branches//;/ })

  if [ -z $branches ]; then
    echo 'No branches to delete...'
    return;
  fi

  echo $branches

  echo 'Do you want to delete these merged branches? (y/n)'
  read yn
  case $yn in
      [^Yy]* ) return;;
  esac

  git remote prune origin
  echo $branches | xargs git branch -d
}

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

# Create a new directory and enter it
function mkcd() {
  mkdir -p "$@" && cd "$@"
}

# export PATH="$HOME/.rbenv/bin:$PATH"
# _evalcache rbenv init - --no-rehash zsh

bindkey "^[[3~" delete-char
