# Yet another dotfiles repository

## Preparation for MacOS

Update system. Install [homebrew](https://brew.sh/). Install zsh with it.

## Installation of environment

Make sure ssh agent is ready to use KeepassXC key (uses $SSH_AUTH_SOCK).
Here will be working example for ArchLinux (btw) and Wayland KDE.

```bash
$ systemctl --user enable --now ssh-agent.service

# kate ~/.config/environment.d/ssh_vars.conf
SSH_AUTH_SOCK=${XDG_RUNTIME_DIR}/ssh-agent.socket
```

Make sure `zsh` is default shell: `chsh -s /usr/bin/zsh`. On Yakuake it will also require to setup another profile, because default one is read-only.

## Things to do after

* Initiate sync on VSCode (I did not have backup outside of proprietary microsoft binaries)
* Import and DO NOT FORGET ultimately TRUST gpg key:

```bash
IMPORT: gpg --import all-private-keys.asc
Check: gpg --list-secret-keys
Trust the imported key: 

gpg --edit-key [key_id]
gpg> trust
  5 = I trust ultimately
Do you really want to set this key to ultimate trust? (y/N) y
gpg> quit
```

## Sidenotes for MacOS

* Setup Ilya Birman's layouts, use layout from `macos/` folder (needs guide)
* iCloud — delete all the syncs (needs guide)
* Setup iTerm2 like guake <https://stackoverflow.com/questions/30850430/iterm2-hide-show-like-guake>
* Sudo with TouchID <https://sixcolors.com/post/2020/11/quick-tip-enable-touch-id-for-sudo/>
* Setup karabiner (I have config but not sure if something else needed)
* Scroll acceleration mouse fix <https://github.com/emreyolcu/discrete-scroll>

### Paid macos apps I use (not in Brewfile)

* Bartender
* BetterSnapTool
* GitKraken
* Cleanshot
* ...

## Sidenotes for Linux

* Setup layouts
  * You need ones with typographic symbols (not sure its easy nowadays, needs guide).
  * Setup CapsLock to change layouts and right Alt as 3rd line modifier.
* Setup guake-like terminal and shortcuts
* Do I need [Wi-fi regulatory domain](https://wiki.cachyos.org/configuration/post_install_setup/#configure-wi-fi-regulatory-domain) to be set on South Korea like router?

## Roadmap

* Implement a cross-platform package installation script in the Makefile for both Homebrew (macOS) and pacman/yay
* Convert hardcoded paths and OS-specific commands in shell scripts (.zshrc, aliases, etc.) into chezmoi templates to ensure they work on both operating systems.
* Create a linux/settings.sh script to configure system settings using gsettings or dconf, similar to macos/defaults.sh
* Make instructions for installing Golang packages like yawn and lazygit.
* Refactor Zsh configuration files to use a numbered prefix for ordered sourcing (e.g., 10-aliases.zsh).
* Create a guide or script for restoring GPG keys from a backup.
* Identify and list Linux equivalents for the macOS GUI applications currently in the Brewfile.
