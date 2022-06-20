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

* Check login Rubymine/Datagrip/Goland
* Launch Docker Desktop
* Launch Gitkraken
* Launch fig
* Launch Raycast
* VSCode - initiate sync
* Restore gpg key – launch keepassxc, search for gpg

## TODO:

5) superhuman / fork / calendar app
7) https://www.taniarascia.com/setting-up-a-brand-new-mac-for-development/
10) screenshot?
11) iterm like guake + always open + ...? tmux? why not
12) closing windows properly
13) shazam krisp twitter (tweetbot)
14) some app to use whatsapp and skype and zoom
15) thefuck? zsh-completions zsh-syntax-highlighting zsh-autosuggestions
16) mackup restore
* brew install dash
* cyberduck
* https://docs.nextcloud.com/server/19/user_manual/pim/sync_osx.html
* Do I need any ssh config? Move from old pc
* Full instruction <https://stackoverflow.com/questions/30850430/iterm2-hide-show-like-guake>
4) https://www.swyx.io/new-mac-setup-2021

## Last things

Check startup -> User & Groups from Raycast
Keyboard -> fn do nothing

## Credits

Its inspired mostly on [webdev dotfiles repo](https://github.com/webpro/dotfiles)
Many thanks to the [dotfiles community](https://dotfiles.github.io).

https://apple.stackexchange.com/questions/232371/el-capitan-remove-finder-from-application-switcher-cmd-tab
https://gist.github.com/germanny/7642823
https://gist.github.com/naotone/d2cbb30cd8d54d34869f
https://github.com/mathiasbynens/dotfiles
https://github.com/alrra/dotfiles
