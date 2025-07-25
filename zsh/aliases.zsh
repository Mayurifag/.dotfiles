## Macos applications
alias firefox='/Applications/Firefox.app/Contents/MacOS/firefox'
alias gitkraken='/Applications/GitKraken.app/Contents/MacOS/GitKraken'

## Folders and files
alias df='df -h'
alias du='du -c -h'

## Root
alias reboot='sudo reboot'
alias root='sudo su'
alias hosts='sudo vim /etc/hosts'

if command -V lsd >/dev/null 2>&1; then 	# Only alias if lsd installed
  alias la='lsd -la'
  alias lt='lsd --tree'
fi

## Other
alias cz='chezmoi'
alias free='free -m' # show sizes in MB
alias myip="timeout 3 dig +short myip.opendns.com @resolver1.opendns.com || timeout 3 curl -s http://ipecho.net/plain" # check ip
alias net="ping ya.ru | grep -E --only-match --color=never '[0-9\.]+ ms'" # check connection including dns
alias bench-network="curl -sL yabs.sh | bash -s -- -fdg"
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

alias fix-mp3-encoding="mp3unicode --source-encoding cp1251 --id3v1-encoding none --id3v2-encoding unicode *"
# https://github.com/soimort/translate-shell
alias tru='trans :ru'
alias ten='trans :en'
alias docker-clean=' \
  docker container prune -f ; \
  docker image prune -f ; \
  docker network prune -f ; \
  docker volume prune -f '
alias bundleantidote='antidote bundle < ~/zsh/plugins.txt > ~/.zsh_plugins.sh'

# Development
## Rails
alias b="bundle exec"
alias bi='bundle install'
alias bu='bundle update'
alias dbc='bundle exec rails dbconsole'
alias rake="noglob rake" # necessary to make rake work inside of zsh (but im not sure)
alias rc='bundle exec rails console'
alias rs='bundle exec rails server'
alias mig='bin/rails db:migrate RAILS_ENV=development'
alias rspec='bundle exec rspec'
alias sort_gemfile='ordinare'
alias tdl='tail -f ./log/development.log'
alias ttl='tail -f ./log/test.log'
alias cr='EDITOR=vim bin/rails credentials:edit'

## Makefile
alias mrc='make rubocop-correct'

## Editors
alias v='nvim'

## Docker
alias dcp='docker-compose'

## Git
alias ci='glab pipeline ci view'
alias gp='[[ -z $(git config "branch.$(git symbolic-ref --short HEAD).merge") ]] && git push -u origin $(git symbolic-ref --short HEAD) || git push'
# alias gpf='LEFTHOOK=0 git push --force'
alias gpf='LEFTHOOK=0 git push origin HEAD --force-with-lease'
alias grc='LEFTHOOK=0 git rebase --continue'
alias gri='LEFTHOOK=0 git rebase --interactive'
alias grep='grep --color=auto'
alias l="lazygit"
# alias q='git add . && git commit -m "$(curl --silent --fail -L https://commit.mayurifag.ru)" && LEFTHOOK=0 git push origin HEAD'
alias q='yawn'
alias qwe='git add . && git commit --amend --no-edit && LEFTHOOK=0 git push --force-with-lease origin HEAD'
alias reset_file='git checkout origin/master'
alias gk='(eval "gitkraken --new-window -p \"$(git rev-parse --show-toplevel)\" -l /dev/null >/dev/null 2>&1 &")'

## Chezmoi
alias czcd='cz cd'
alias czapply='cz apply -v'
