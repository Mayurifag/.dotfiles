# Yet another dotfiles repository


* Install zsh dip redshiftgrc delta colordiff
* git clone git@github.com:Mayurifag/.dotfiles.git
* cp gitconfig.example gitconfig
* create zsh/private_aliases.zsh

## Install asdf and antibody

- git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.7.3
- asdf update
- //todo: global .tool_versions // install/update ruby nodejs go
- //yarn?
bash ~/.asdf/plugins/nodejs/bin/import-release-team-keyring
- sudo chmod 777 /usr/local/bin/
- sudo install antibody
- uz

* ./install

### uz

Update and initialize cached

## Since macos

## Highlights

- Minimal efforts to install everything, using a [Makefile](./Makefile)
- Mostly based around Homebrew, Caskroom and Node.js, latest Bash + GNU Utils
- Fast and colored prompt
- Updated macOS defaults
- Well-organized and easy to customize
- The installation and runcom setup is [tested weekly on real Ubuntu and macOS
  machines](https://github.com/Mayurifag/.dotfiles/actions) (Big Sur and Monterey;
  Catalina should still be fine too) using [a GitHub
  Action](./.github/workflows/ci.yml)
- Supports both Apple Silicon (M1) and Intel chips

## Packages Overview

- [Homebrew](https://brew.sh) (packages: [Brewfile](./install/Brewfile))
- [homebrew-cask](https://github.com/Homebrew/homebrew-cask) (packages: [Caskfile](./install/Caskfile))
- [Node.js + npm LTS](https://nodejs.org/en/download/) (packages: [npmfile](./install/npmfile))
- Latest Git, Bash 4, Python 3, GNU coreutils, curl, Ruby
- [Mackup](https://github.com/lra/mackup) (sync application settings)
- `$EDITOR` (and Git editor) is [GNU nano](https://www.nano-editor.org)

## Installation

On a sparkling fresh installation of macOS:

```bash
sudo softwareupdate -i -a
xcode-select --install
```

The Xcode Command Line Tools includes `git` and `make` (not available on stock macOS). Now there are two options:

1. Install this repo with `curl` available:

```bash
bash -c "`curl -fsSL https://raw.githubusercontent.com/Mayurifag/.dotfiles/master/remote-install.sh`"
```

This will clone or download, this repo to `~/.dotfiles` depending on the availability of `git`, `curl` or `wget`.

1. Alternatively, clone manually into the desired location:

```bash
git clone https://github.com/Mayurifag/.dotfiles.git ~/.dotfiles
```

Use the [Makefile](./Makefile) to install everything [listed above](#package-overview), and symlink [runcom](./runcom)
and [config](./config) (using [stow](https://www.gnu.org/software/stow/)):

```bash
cd ~/.dotfiles
make
```

The installation process in the Makefile is tested on every push and every week in this
[GitHub Action](https://github.com/Mayurifag/.dotfiles/actions).

## Post-Installation

- `dot dock` (set [Dock items](./macos/dock.sh))
- `dot macos` (set [macOS defaults](./macos/defaults.sh))
- Mackup
  - Log in to Dropbox (and wait until synced)
  - `ln -s ~/.config/mackup/.mackup.cfg ~` (until [#632](https://github.com/lra/mackup/pull/632) is fixed)
  - `mackup restore`

## The `dotfiles` command

```bash
$ dot help
Usage: dot <command>

Commands:
    clean            Clean up caches (brew, npm, gem, rvm)
    dock             Apply macOS Dock settings
    edit             Open dotfiles in IDE (code) and Git GUI
    help             This help message
    macos            Apply macOS system defaults
    test             Run tests
    update           Alias for topgrade
```

## Customize

To customize the dotfiles to your likings, fork it and make sure to modify the locations above to your fork.

## After bootstrap

1) Install Gitkraken (+ ...)
2) https://docs.nextcloud.com/server/19/user_manual/pim/sync_osx.html

## Credits

Its inspired mostly on [webdev dotfiles repo](https://github.com/webpro/dotfiles)
Many thanks to the [dotfiles community](https://dotfiles.github.io).

https://apple.stackexchange.com/questions/232371/el-capitan-remove-finder-from-application-switcher-cmd-tab
https://gist.github.com/germanny/7642823
https://gist.github.com/naotone/d2cbb30cd8d54d34869f
https://github.com/mathiasbynens/dotfiles
https://github.com/alrra/dotfiles
