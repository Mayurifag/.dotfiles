# Everyday Linux
## This ZSH config. You may do d-enter-f-enter to get this repo opened fast in vscode
alias d='cd $HOME/.dotfiles/'

## Folders and files
alias df='df -h'
alias du='du -c -h'
alias ll='ls -alh'
alias diff='colordiff' # requires colordiff package
alias mkdir='mkdir -p -v'
alias more='less'
alias nano='nano -w'
alias perms="stat -c '%A %a %n'" # octal+text permissions for files

if command -V dircolors >/dev/null 2>&1; then 	# Only alias ls colors if dircolors is installed
	# eval "$(dircolors -b)"
	alias dir="dir --color=auto"
	alias ls="ls -F --color=auto"
	alias vdir="vdir --color=auto"
  alias egrep='egrep --color=auto'
  alias fgrep='fgrep --color=auto'
fi

## Root
alias reboot='sudo reboot'
alias root='sudo su'
alias scat='sudo cat'

## Other
alias rsa='xclip -sel clip < ~/.ssh/id_rsa.pub'
alias free='free -m'                # show sizes in MB
alias myip="timeout 3 dig +short myip.opendns.com @resolver1.opendns.com || timeout 3 curl -s http://ipecho.net/plain" # check ip
alias net="ping ya.ru | grep -E --only-match --color=never '[0-9\.]+ ms'" # check connection including dns
alias vboost='pamixer --allow-boost --set-volume 150'
alias u="yay -Syu"
alias weather='curl wttr.in/SVO'
alias yt="youtube-dl -o '%(title)s.%(ext)s'"
alias yta="youtube-dl -o '%(title)s.%(ext)s' --extract-audio --audio-format 'mp3'"
# https://github.com/soimort/translate-shell
# need to install first
alias tru='trans :ru'
alias ten='trans :en'

# Development
## Rails
alias b="bundle exec"
alias bi='bundle install'
alias bu='bundle update'
alias dbc='bundle exec rails dbconsole'
alias rake="noglob rake" # necessary to make rake work inside of zsh (but im not sure)
alias rc='bundle exec rails console'
alias rs='bundle exec rails server'
alias rspec='bundle exec rspec'
alias sort_gemfile='ordinare'
alias tdl='tail -f ./log/development.log'
alias ttl='tail -f ./log/test.log'

## VSCode
alias f='code .'
alias config='code ~/.zshrc'

## Docker
alias dcp='docker-compose'
alias dp='dip provision'
alias l='docker run -it -v /var/run/docker.sock:/var/run/docker.sock -v $HOME/.dotfiles/lazydocker:/.config/jesseduffield/lazydocker lazyteam/lazydocker'

## Git
alias g='git'
alias gp='[[ -z $(git config "branch.$(git symbolic-ref --short HEAD).merge") ]] && git push -u origin $(git symbolic-ref --short HEAD) || git push'
alias gpf='git push --force'
alias grc='git rebase --continue'
alias grep='grep --color=auto'
alias grep='grep --color=auto'
alias grom='LEFTHOOK=0 git rebase -i origin/master'
alias lzg="lazygit"
alias q='git add . && git commit -m "WIP: $(curl -s http://whatthecommit.com/index.txt)" && git push origin HEAD'
alias reset_file='git checkout origin/master'
alias yolo='LEFTHOOK=0 git push --force'

## Vagrant
alias vp="vagrant provision"
alias vs="vagrant ssh"
alias vz="vagrant destroy -f; vagrant up"
