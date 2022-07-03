# Yet another dotfiles repository

## WIP

Repository is flagged as work in progress. There are things that aren't working now. For example, installation is not
idempotent and make all not working as expected. Each command should be executed one by one.

## Installation

On a sparkling fresh installation of macOS:

```bash
sudo softwareupdate -i -a
xcode-select --install
```

The Xcode Command Line Tools includes `git` and `make` (not available on stock macOS). Now there are two options:

Install this repo with `curl` available:

```bash
bash -c "`curl -fsSL https://raw.githubusercontent.com/Mayurifag/.dotfiles/master/remote-install.sh`"
```

This will clone or download, this repo to `~/.dotfiles` depending on the availability of `git`, `curl` or `wget`.

Alternatively, clone manually into the desired location:

```bash
git clone https://github.com/Mayurifag/.dotfiles.git ~/.dotfiles
```

```bash
cd ~/.dotfiles
make
```

## Before

* Install zsh and make homebrew one to be default

## After bootstrap

* VSCode - initiate sync
* Restore gpg key – launch keepassxc, search for gpg
* Setup each app

## TODO:

5) superhuman / fork / calendar app
7) https://www.taniarascia.com/setting-up-a-brand-new-mac-for-development/
12) closing windows properly
13) krisp twitter (tweetbot)
14) some app to use whatsapp and skype and zoom
16) mackup restore
* cyberduck
* https://docs.nextcloud.com/server/19/user_manual/pim/sync_osx.html
* Do I need any ssh config? Move from old pc
* Full instruction <https://stackoverflow.com/questions/30850430/iterm2-hide-show-like-guake>

## Last things

Check startup -> User & Groups from Raycast
Keyboard -> fn do nothing

## Startup

Hidden telegram app in script editor

```
run application "Telegram"
tell application "Finder"
set visible of process "Telegram" to false
end tell
```

Need to think :S

## Set sudo to be usable without Touch ID

<https://sixcolors.com/post/2020/11/quick-tip-enable-touch-id-for-sudo/>

## Set up shadowsocks

TODO

## Setup karabiner

TODO
make caps lock switch languages and make it fast!

## Scroll acceleration mouse fix

<https://github.com/iwa/discrete-scroll-arm>

## Раскладка Бирмана

Установить + удалить системный английский язык.

## Redquits - do i need it

sudo installer -verbose -pkg RedQuits_v2.pkg -target /
Privacy -> Accessibility -> enable

## ani-cli

<https://github.com/pystardust/ani-cli#MacOS>

## Paid macos apps I use

1) Bartender 4
2) BetterSnapTool
3) GitKraken
4) Rubymine/Datagrip/Goland (login)

## Credits

Its inspired mostly on [webdev dotfiles repo](https://github.com/webpro/dotfiles)
Many thanks to the [dotfiles community](https://dotfiles.github.io).

https://apple.stackexchange.com/questions/232371/el-capitan-remove-finder-from-application-switcher-cmd-tab
https://gist.github.com/germanny/7642823
https://gist.github.com/naotone/d2cbb30cd8d54d34869f
https://github.com/mathiasbynens/dotfiles
https://github.com/alrra/dotfiles
