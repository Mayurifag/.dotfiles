## Folders and files
alias df='df -h'
alias du='du -c -h'
alias ls='ls -alh'

## Root
alias reboot='sudo reboot'
alias root='sudo -i'

## Other
alias c="clear"
alias free='free -m' # show sizes in MB
alias myip="timeout 3 dig +short myip.opendns.com @resolver1.opendns.com || timeout 3 curl -s http://ipecho.net/plain" # check ip
alias net="ping ya.ru | grep -E --only-match --color=never '[0-9\.]+ ms'" # check connection including dns
alias bench-network="curl -sL yabs.sh | bash -s -- -fdg"
alias grep='grep --color=auto'
alias make="make -j`nproc`"

## yt-dlp
alias yt="yt-dlp -v -o \"%(title)s.%(ext)s\" -f bv*+?ba/b --extractor-args \"youtube:player_client=default,ios\" -S hdr:dv,res,vcodec:av1,acodec:opus,br --sponsorblock-mark all --sponsorblock-remove \"sponsor,selfpromo,interaction,intro,outro,preview,music_offtopic\" --embed-thumbnail --embed-chapters --embed-metadata --concurrent-fragments 3 --throttled-rate 100K --retries 3"
alias yt-full="yt-dlp -v -o \"%(upload_date)s %(title)s.%(ext)s\" -f bv*+?ba/b --extractor-args \"youtube:player_client=default,ios\" -S hdr:dv,res,vcodec:av1,acodec:opus,br --sponsorblock-mark all --sponsorblock-remove \"sponsor,selfpromo,interaction,intro,outro,preview,music_offtopic\" --embed-thumbnail --embed-chapters --embed-metadata --embed-subs --sub-langs all --concurrent-fragments 3 --throttled-rate 100K --retries 3"
alias yta="yt-dlp -f 'ba' -x --audio-format mp3 --audio-quality 0 \
  -o '%(artist,uploader|Unknown Artist)s - %(title)s.%(ext)s' \
  --embed-thumbnail --convert-thumbnails jpg \
  --embed-metadata \
  --parse-metadata 'title:%(title)s' \
  --parse-metadata 'artist:%(artist,uploader|Unknown Artist)s' \
  --sponsorblock-remove 'sponsor,selfpromo,interaction,intro,outro,preview,music_offtopic' \
  --sponsorblock-chapter-title '[SponsorBlock]: %(category)s' \
  --embed-chapters \
  --concurrent-fragments 3 \
  --throttled-rate 100K \
  --retries 10 \
  --no-playlist"

# https://github.com/soimort/translate-shell
alias tru='trans :ru'
alias ten='trans :en'

alias bundleantidote='antidote bundle < ~/zsh/plugins.txt > ~/zsh/.zsh_plugins.sh'
alias brewfile='brew bundle dump --file=$(chezmoi source-path)/install/Brewfile --force --no-vscode'
alias updatedesktopdb='update-desktop-database ~/.local/share/applications/'

# Development
## Rails
# alias b="bundle exec"
# alias bi='bundle install'
# alias bu='bundle update'
# alias dbc='bundle exec rails dbconsole'
# alias rake="noglob rake" # necessary to make rake work inside of zsh (but im not sure)
# alias rc='bundle exec rails console'
# alias rs='bundle exec rails server'
# alias mig='bin/rails db:migrate RAILS_ENV=development'
# alias rspec='bundle exec rspec'
# alias sort_gemfile='ordinare'
# alias tdl='tail -f ./log/development.log'
# alias ttl='tail -f ./log/test.log'
# alias cr='EDITOR=vim bin/rails credentials:edit'
# alias mrc='make rubocop-correct'

## Editors
alias vi='vim'
alias v='vim'

## Docker
alias dcp='docker-compose'
alias docker-clean=' \
  docker container prune -f ; \
  docker image prune -f ; \
  docker network prune -f ; \
  docker volume prune -f '

## Git
alias ci='glab pipeline ci view'
alias gp='[[ -z $(git config "branch.$(git symbolic-ref --short HEAD).merge") ]] && git push -u origin $(git symbolic-ref --short HEAD) || git push'
alias gpf='LEFTHOOK=0 git push origin HEAD --force-with-lease'
alias grc='LEFTHOOK=0 git rebase --continue'
alias gri='LEFTHOOK=0 git rebase --interactive'
alias l="lazygit"
alias q='yawn'
alias qwe='git add . && git commit --amend --no-edit && LEFTHOOK=0 git push --force-with-lease origin HEAD'
alias reset_file='git checkout origin/master'
if [ ! -x "$(command -v gitkraken)" ]; then
  alias gitkraken='/Applications/GitKraken.app/Contents/MacOS/GitKraken'
fi
alias gk='(eval "gitkraken --new-window -p \"$(git rev-parse --show-toplevel)\" -l /dev/null >/dev/null 2>&1 &")'

## Chezmoi
alias cz='chezmoi'
alias czcd='cz cd'
alias czapply='cz apply -v'
alias fakeczapply='chezmoi apply -v --dry-run'
alias pub='ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKc+qX1yWHK1A1vVHrL7HcqAQZrhZnPywCTrcMHB/z/b ed25519-vlad'
