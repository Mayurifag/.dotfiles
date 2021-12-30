# Update Zsh plugins
uz(){
  antibody bundle < ~/.dotfiles/zsh/plugins.txt > ~/.zsh_plugins.sh
  antibody update
  asdf plugin-update ruby
  asdf plugin-update yarn
  asdf plugin-update golang
}

pollCommand() {
    while true; do clear; $@; sleep 1; done
}

prg() {
  git pull -a > /dev/null

  local branches=$(git branch | grep -v 'release' | grep -v 'master' | grep -v "\*" )
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
delhost() { sed -i "$1d" ~/.ssh/known_hosts } # i dont use that

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

lock () {
  cd ~/Code/windowed-game-mouse-lock
  npm start
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

gitself() {
  echo 'Setting up user Vladisav Ponomarev <farazeus@gmail.com>'
  git config user.name 'Vladislav Ponomarev' && git config user.email 'farazeus@gmail.com' && git config user.signingKey 'E8E136A2C8865C488DB0B5CBBCE113E227780CF7'
}

gitwork() {
  echo 'Setting up user Vladisav Ponomarev <vladislav.ponomarev@bgaming.com>'
  git config user.name 'Vladislav Ponomarev' && git config user.email 'vladislav.ponomarev@bgaming.com' && git config user.signingKey 'E8E136A2C8865C488DB0B5CBBCE113E227780CF7'
}

gcd() {
  git clone --recurse-submodules "$1" && cd "$(basename "$1" .git)" && gitself
}

gitf() {
  git filter-repo -f --prune-empty always --refs maingk $(git tag -l) --mailmap ~/.dotfiles/.mailmap
}
