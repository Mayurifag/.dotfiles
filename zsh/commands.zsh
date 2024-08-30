pollCommand() {
    while true; do clear; $@; sleep 1; done
}

prg() {
  git pull -a > /dev/null

  local branches=$(git branch --list '*[^master][^main]' --format='%(refname:short)' | grep -v '^*')
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

# -------------------------------------------------------------------
# compressed file expander
# (from https://github.com/myfreeweb/zshuery/blob/master/zshuery.sh)
# -------------------------------------------------------------------
ex() {
    if [[ -f $1 ]]; then
        case $1 in
            *.tar.bz2) tar xvjf $1;;
            *.tar.gz) tar xvzf $1;;
            *.tar.xz) tar xvJf $1;;
            *.tar.lzma) tar --lzma xvf $1;;
            *.bz2) bunzip $1;;
            *.rar) unrar $1;;
            *.gz) gunzip $1;;
            *.tar) tar xvf $1;;
            *.tbz2) tar xvjf $1;;
            *.tgz) tar xvzf $1;;
            *.zip) unzip $1;;
            *.Z) uncompress $1;;
            *.7z) 7z x $1;;
            *.dmg) hdiutul mount $1;; # mount OS X disk images
            *) echo "'$1' cannot be extracted via >ex<";;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Usage: spl paranoya
# & paranoya 8 0: paranoia, Parana, paranoiac (as you see the first option after the 0, gives the correct spelling
spl () {
  aspell -a <<< "$1"
}

# Delete a given line number in the known_hosts file.
# Alternative: ssh-keygen -R 182.123.212.21
knownrm() {
 re='^[0-9]+$'
 if ! [[ $1 =~ $re ]] ; then
   echo "error: line number missing" >&2;
 else
   sed -i '' "$1d" ~/.ssh/known_hosts
 fi
}

gcd() {
  git clone --recurse-submodules "$1" && cd "$(basename "$1" .git)"
}

grom () {
  if git rev-parse --verify --quiet origin/main > /dev/null 2>&1; then
    GIT_BRANCH=main
  elif git rev-parse --verify --quiet origin/master > /dev/null 2>&1; then
    GIT_BRANCH=master
  elif git rev-parse --verify --quiet origin/source > /dev/null 2>&1; then
    GIT_BRANCH=source
  else
    echo "Neither 'origin/main' nor 'origin/master' branch exists."
    return 1
  fi

  LEFTHOOK=0 git rebase -i "origin/$GIT_BRANCH"
  git submodule update --init --recursive
}

btrestart() {
  sudo rfkill block bluetooth && sleep 0.1 && sudo rfkill unblock bluetooth
}

# -i path/to/input_file: give the path to your file
# -c copy: tell FFmpeg to copy codecs (prevent transcoding)
# -an: disables audio
remove_audio() {
  ffmpeg -i $1 -c copy -an onlyVideo.mp4
}

leet() {
  filename=$(echo "$@" | tr ' ' '_' | tr '[:upper:]' '[:lower:]')
  mkdir -p ${filename}
  touch ${filename}/${filename}.go
  echo "package leetcode" >> ${filename}/${filename}.go
}

leetest() {
  gotests -w -all -parallel $1
}

ports() {
  sudo lsof -iTCP -sTCP:LISTEN -n -P | awk 'NR>1 {print $9, $1, $2}' | sed 's/.*://' | while read port process pid; do echo "Port $port: $(ps -p $pid -o command= | sed 's/^-//') (PID: $pid)"; done | sort -n
}
