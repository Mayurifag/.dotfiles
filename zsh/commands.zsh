pollCommand() {
    while true; do clear; $@; sleep 1; done
}

prg() {
  git pull -a > /dev/null

  local branches=$(git branch | grep -v 'development' | grep -v 'release' | grep -v 'develop' | grep -v 'master' | grep -v 'qa' | grep -v "\*" )
  branches=(${branches//;/ })

  if [ -z $branches ]; then
    echo 'No branches to delete.'
    return;
  fi

  echo $branches

  echo 'Do you want to delete these merged branches? (y/n)'
  read yn
  case $yn in
      [^Yy]* ) return;;
  esac

  git remote prune origin
  echo $branches | xargs git branch -D
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
mkcd() {   [ -n "$1" ] && mkdir -p "$@" && cd "$1";   }

pskill(){
    ps aux | grep "$1" | grep -v grep | awk '{print $2;}' | while read p; do kill -9 $p; done
}

backup() { cp "$1"{,.bak};}

extract() {
    if [ -f $1 ] ; then
      case $1 in
        *.tar.bz2)   tar xjf $1     ;;
        *.tar.gz)    tar xzf $1     ;;
        *.bz2)       bunzip2 $1     ;;
        *.rar)       unrar e $1     ;;
        *.gz)        gunzip $1      ;;
        *.tar)       tar xf $1      ;;
        *.tbz2)      tar xjf $1     ;;
        *.tgz)       tar xzf $1     ;;
        *.zip)       unzip $1       ;;
        *.Z)         uncompress $1  ;;
        *.7z)        7z x $1        ;;
        *)     echo "'$1' cannot be extracted via extract()" ;;
         esac
     else
         echo "'$1' is not a valid file"
     fi
}

# for those who struggle spelling! This will take your best guess and give you a list of what you probably meant.
#usage: spl paranoya
# & paranoya 8 0: paranoia, Parana, paranoiac (as you see the first option after the 0, gives the correct spelling
spl () {
    aspell -a <<< "$1"
}
