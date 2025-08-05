# Setup environment cheatsheet

Yes, that's better to be NixOS config here, but I use arch (btw).

## Preparation for MacOS

* Update system. Install [homebrew](https://brew.sh/).
* You will need to install homebrew' `zsh` and be sure you switched to it.
* Setup iTerm2 like [guake](https://stackoverflow.com/questions/30850430/iterm2-hide-show-like-guake)

## Preparation for Linux

* Setup font: use `JetBrains Mono Nerd Font` 11pt for `monospace` and `San Francisco` apple font for other things.
* Nextcloud from Appimage works better than any version, idk why.
* Setup ssh agent. Here will be working example for ArchLinux (btw) and Wayland KDE.

```bash
$ systemctl --user enable --now ssh-agent.service

# kate ~/.config/environment.d/ssh_vars.conf
SSH_AUTH_SOCK=${XDG_RUNTIME_DIR}/ssh-agent.socket
```

Make sure `zsh` is default shell: `chsh -s /usr/bin/zsh`. For Yakuake it will also require to setup another profile, because default one is read-only. For profile colors choose `Klorax. Dracula transparent`.

## Installation of environment

* Set `dracula` theme everywhere you can, starting from terminal.
* Go to KeepassXC and check that it works with ssh-agent. `ssh-add -l` has to print key which works with Github.
* Install `chezmoi` and `mise` using your system manager.

Apply `.dotfiles`:

```bash
chezmoi cd
chezmoi init git@github.com:Mayurifag/.dotfiles.git
chezmoi diff # preview
chezmoi apply
```

* Open new tab and bundle antidote plugins `bundleantidote`.
* Open new tab and see if something else is wrong.
* Install packages for all languages and tools: `make mise-packages`

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

* Install and configure gitkraken. Make sure it updates or not either itself or with package manager:

```txt
# /etc/hosts
...
0.0.0.0 release.gitkraken.com # prevent autoupdates of gitkraken because its managed with package manager
```

## Sidenotes for MacOS

* Setup Raycast
* Setup Ilya Birman's layouts, use layout from `macos/` folder (needs guide)
* iCloud — delete all the syncs (needs guide)
* Sudo with TouchID <https://sixcolors.com/post/2020/11/quick-tip-enable-touch-id-for-sudo/>
* Setup karabiner (I have config but not sure if something else needed)
* Scroll acceleration mouse fix <https://github.com/emreyolcu/discrete-scroll>
* After orbstack installation check docker commands working for regular user. Also `docker login -u $USER`.

### Paid macos apps I use (not in Brewfile)

* Bartender
* BetterSnapTool
* GitKraken
* Cleanshot
* ...

## Sidenotes for Linux

* Run `updatedesktopdb` alias after installing `arch-packages` and `chezmoi` things.
* Setup layouts
  * You need ones with typographic symbols (not sure its easy nowadays, needs guide).
  * Setup CapsLock to change layouts and right Alt as 3rd line modifier.
* Setup guake-like terminal and shortcuts
* Setup [Wi-fi regulatory domain](https://wiki.cachyos.org/configuration/post_install_setup/#configure-wi-fi-regulatory-domain) to South Korea:

```txt
# /etc/conf.d/wireless-regdom
WIRELESS_REGDOM="KR"
```

* Prevent updating of gitkraken:

```txt
# /etc/pacman.conf
...
IgnorePkg = gitkraken
```

* Activate docker socket and group

```bash
sudo systemctl enable --now docker.service
sudo groupadd docker # Check or create group docker
sudo gpasswd -a $USER docker
docker login -u $USER
```

## Roadmap

* Keepassxc-cli and yawn config template
* Try to run `mise packages`
* ignore bracketed paste mode research - zsh
* CachyOS zsh aliases config check for interesting things
* cron.d/ for cleaning caches packages docker and so on
* /etc/fstab for windows disks
* Check if fonts ssh-vars had impact
* <https://mikeshade.com/posts/docker-native-overlay-diff/>
* Obsidian
  * Watch for KVM - need full edid emulation, fast switch, configurable hotkey to switch, 2x2 hdmi, usb3.0, configurable indicators also
* <https://mvalvekens.be/blog/2022/docker-dbus-secrets.html> ? Have to check this on macos first
* Autocompletions full fixes. Zcompdump and else. [Mise autocompletions btw](https://mise.jdx.dev/installing-mise.html#autocompletion)
* Convert hardcoded paths and OS-specific commands in shell scripts (.zshrc, aliases, etc.) into chezmoi templates to ensure they work on both operating systems.
* Refactor Zsh configuration files to use a numbered prefix for ordered sourcing (e.g., 10-aliases.zsh).
* Create a guide or script for restoring GPG keys from a backup.
* Identify and list Linux equivalents for the macOS GUI applications currently in the Brewfile.
