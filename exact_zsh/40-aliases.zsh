## Folders and files
alias df='df -h'
alias du='du -c -h'

if if_command_exists eza; then
  alias ls='eza -lh --group-directories-first'
  alias l='eza --git-ignore --group-directories-first'
  alias ll='eza --all --header --long --group-directories-first'
  alias llm='eza --all --header --long --sort=modified --group-directories-first'
  alias la='eza -lbhHigUmuSa'
  alias lx='eza -lbhHigUmuSa@'
  alias lt='eza --tree'
  alias tree='eza --tree'
  alias exa='eza'
else
  alias ls='ls --color -alh'
fi

alias ..='builtin cd ..'
alias ...='buitin cd ...'
alias ....='builtin cd ....'

## Root
alias reboot='sudo reboot'
alias root='sudo -i'

## Other
alias free='free -m' # show sizes in MB
alias myip="timeout 3 dig +short myip.opendns.com @resolver1.opendns.com || timeout 3 curl -s http://ipecho.net/plain" # check ip
alias net="ping ya.ru | grep -E --only-match --color=never '[0-9\.]+ ms'" # check connection including dns
alias bench-network="curl -sL yabs.sh | bash -s -- -fdg"
alias grep='grep --color=auto'
alias y='yay'

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
alias yabs='curl -sL https://yabs.sh | bash'
alias c='claude --dangerously-skip-permissions'

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
alias gp='[[ -z $(git config "branch.$(git symbolic-ref --short HEAD).merge") ]] && git push -u origin $(git symbolic-ref --short HEAD) || git push'
alias gpf='LEFTHOOK=0 git push origin HEAD --force-with-lease'
alias grc='LEFTHOOK=0 git rebase --continue'
alias gri='LEFTHOOK=0 git rebase --interactive'
alias gl='jj log'
alias lzg='lazygit'
alias q='yawn'
alias qwe='git add . && git commit --amend --no-edit && LEFTHOOK=0 git push --force-with-lease origin HEAD'
alias reset_file='git checkout origin/master'
if ! if_command_exists gitkraken; then
  alias gitkraken='/Applications/GitKraken.app/Contents/MacOS/GitKraken'
fi
alias gk='(eval "gitkraken --new-window -p \"$(git rev-parse --show-toplevel)\" -l /dev/null >/dev/null 2>&1 &")'
alias g='gk'

## Chezmoi
alias cz='chezmoi'
alias czcd='chezmoi cd'
alias czapply='chezmoi apply -v && source "$HOME/.zshrc"'
alias fakeczapply='chezmoi apply -v --dry-run'
