# Setup environment cheatsheet

Yes, that's better to be NixOS config here, but I use arch (btw).

## Preparation for MacOS

* Update system. Install [homebrew](https://brew.sh/).
* You will need to install homebrew' `zsh` and be sure you switched to it.
* Setup iTerm2 like [guake](https://stackoverflow.com/questions/30850430/iterm2-hide-show-like-guake)

## Preparation for Linux

It mostly implies you should use KDE on Wayland.

* Setup font: use `JetBrains Mono Nerd Font` 11pt for `monospace` and
  `San Francisco` apple font for other things.
* Nextcloud from Appimage works better than any version, idk why.
* KeepassXC with custom browsers requires
  `Browser integration -> Advanced -> Use a custom browser configuration`.
  For example, Thorium requires to have `Chromium` type and
  `~/.config/thorium/NativeMessagingHosts` there.
* Setup ssh agent. Here will be working example for ArchLinux (btw) and Wayland KDE.

```bash
$ systemctl --user enable --now ssh-agent.service

# kate ~/.config/environment.d/ssh_vars.conf
SSH_AUTH_SOCK=${XDG_RUNTIME_DIR}/ssh-agent.socket
```

Make sure `zsh` is default shell: `chsh -s /usr/bin/zsh`. For Yakuake it will
also require to setup/choose another profile, because default one is read-only.

## Installation of environment

* Set `dracula` theme everywhere you can, starting from terminal.
* Go to KeepassXC and check that it works with ssh-agent. `ssh-add -l` has to
  print key which works with Github.
* Install `chezmoi`, `mise` and `ejson` using your system manager.

```bash
sudo ln -s $HOME/Nextcloud/ejson/ /opt/ejson # or any other way to export your ejson key
```

Apply `.dotfiles`:

```bash
chezmoi cd
chezmoi init git@github.com:Mayurifag/.dotfiles.git
chezmoi diff # preview
chezmoi apply
```

* Install packages for all languages and tools: `make mise-packages`

## Things to do after

* Initiate sync on VSCode (I did not have backup outside of proprietary
  microsoft binaries)
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

* Install and configure gitkraken. Make sure it updates or not either itself
  or with package manager:

```txt
# /etc/hosts
# prevent autoupdates of gitkraken because its managed with package manager
0.0.0.0 release.gitkraken.com
```

* Setup external disks like windows one or samba or whatever
* Setup espanso. On MacOS go through Accessibility "privacy" hell first.

```shell
sudo setcap "cap_dac_override+p" $(which espanso) # for wayland
espanso service register
espanso start # its for linux, on macos launch app and go through accessibility hell
# ... # cron setup for macos with espanso restart due to memory leaking
```

* Setup obsidian (use nextcloud)

## Sidenotes for MacOS

* Setup Raycast
* Setup Ilya Birman's layouts, use layout from `macos/` folder (needs guide)
* iCloud — delete all the syncs (needs guide)
* Sudo with TouchID <https://sixcolors.com/post/2020/11/quick-tip-enable-touch-id-for-sudo/>
* Setup karabiner (I have config but not sure if something else needed)
* Scroll acceleration mouse fix <https://github.com/emreyolcu/discrete-scroll>
* After orbstack installation check docker commands working for regular user.

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
* Setup [Wi-fi regulatory domain](https://wiki.cachyos.org/configuration/post_install_setup/#configure-wi-fi-regulatory-domain)
  to South Korea:

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

* Enable native overlay diff engine to speed up building images in docker
  (info from ArchWiki):

```bash
$ kate /etc/modprobe.d/disable-overlay-redirect-dir.conf
options overlay metacopy=off redirect_dir=off
$ modprobe -r overlay
$ modprobe overlay
```

* Activate docker socket and group

```bash
sudo systemctl enable --now docker.service
sudo groupadd docker # Check or create group docker
sudo gpasswd -a $USER docker
docker info # run docker info and check that Native Overlay Diff is true
```

* Setup bluetooth (maybe
  [dualboot](https://konfekt.github.io/blog/2023/05/21/bluetooth-sync-keys-windows-linux-dualboot#low-energy-devices))
* Setup shortcuts:

```conf
Dolphin: Alt+E # a-la macos
Spectacle: Rectangular region on Alt+1 (Alt+!) # screenshot tool, I dont think I need other functions
Yakuake: Alt+`, Ctrl+` # terminal. Alt+` for a-la macos
Krunner: Meta+Space
```

* Clean system time to time: `sudo systemctl enable --now yaycache.timer`
* Install `nerd-dictation`. That will require to install `ydotool` and its setup
  for wayland. Install model.
* Enable asterisks on sudo password: `echo 'Defaults pwfeedback' | sudo tee /etc/sudoers.d/20-pwfeedback`
* <https://wiki.cachyos.org/configuration/gaming/#increase-maximum-shader-cache-size>
* Use mvln for compatdata [NTFS mount](https://github.com/ValveSoftware/Proton/wiki/Using-a-NTFS-disk-with-Linux-and-Windows)

## Notes

* Repo is using [ejson](https://github.com/Shopify/ejson) with keys.ejson file,
  which is needed to be reencrypted on changes:

```shell
ejson decrypt keys.ejson
# edit ...
ejson encrypt keys.ejson
```

* If previous command did required sudo, you may do Esc+Esc in terminal due to
  `zsh-sudo` plugin
* Bluetooth for dualboot requires a lot of attention because of many updates
  going on on win and bluez sides.
* Example of `/etc/fstab` entry for shared NTFS partition:

```bash
$ sudo -i
# mkdir /mnt/Shared
# kate /etc/fstab
PARTUUID="61ffcf10-e472-4c71-8e04-cf57c6463e6b" /mnt/Shared   ntfs3   \
uid=1000,gid=1000,umask=000,nofail,noatime,user,exec 0 0
```

* If some shit goes with Privacy in MacOS settings, try to remove entry with
  little buttons and launch app once again to go through that hell once more.

* Claude code configuration inspired by [this repo](https://github.com/roderik/ai-rules)

* [Playwright installation](https://github.com/microsoft/playwright/issues/2621#issuecomment-2083083392)
