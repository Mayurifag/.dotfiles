# Setup environment cheatsheet

That is my dotfiles repository and little cheatsheet on how to setup my systems.
It works on MacOS/Windows 11/CachyOS (Linux). Windows one differs from others,
so I put it on [another instruction file](./windows/INSTRUCTION.md).

## Preparation for MacOS

* Update system. Install [homebrew](https://brew.sh/).
* You will need to install homebrew' `zsh` and be sure you switched to it.
* Setup iTerm2 like [guake](https://stackoverflow.com/questions/30850430/iterm2-hide-show-like-guake)

## Preparation for Linux

It mostly implies you should use KDE on Wayland.

* Setup font: use `JetBrains Mono Nerd Font` 11pt for `monospace` and
  `San Francisco` font for other things.
* Setup CapsLock to change layouts
* KeepassXC with custom browsers requires
  `Browser integration -> Advanced -> Use a custom browser configuration`.
* Setup ssh agent. Here will be working example for ArchLinux (btw) and Wayland KDE.

```bash
$ systemctl --user enable --now ssh-agent.service

# kate ~/.config/environment.d/ssh_vars.conf
SSH_AUTH_SOCK=${XDG_RUNTIME_DIR}/ssh-agent.socket
```

Make sure `zsh` is default shell: `chsh -s /usr/bin/zsh`. For Yakuake it will
also require to setup/choose another profile, because default one is read-only.

* Add user to input/uinput (for kanata):

```sh
sudo usermod -aG input "$USER"
sudo usermod -aG uinput "$USER"
```

## Installation of environment

* Set `dracula` theme everywhere you can, starting from terminal.
* Go to KeepassXC and check that it works with ssh-agent. `ssh-add -l` has to
  print key which works with Github.
* Install `mise` using your system manager.

```bash
sudo ln -s /Volumes/exfat/OpenCloud/Personal/Software/dotfiles/ejson /opt/ejson # or any other way to export your ejson key
```

Apply `.dotfiles`:

```bash
chezmoi cd
chezmoi init git@github.com:Mayurifag/.dotfiles.git --ssh
chezmoi diff # preview
chezmoi apply
```

* Install packages for all languages and tools: `make mise-packages`

## Things to do after

* Authenticate GitHub CLI (token stored in OS keyring — same on macOS/Linux):

```bash
gh auth login
# → GitHub.com → SSH → Login with a web browser
```

* Initiate sync on VSCode
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

* Install and configure gitkraken (ssh from system, etc.)
* Setup external disks (router or else)
* Setup Obsidian
* Setup [Browsers.app](https://browsers.software/) as default browser
* Setup `gsd` - login. Perhaps also needed model/thinking levels, not sure

## Sidenotes for MacOS

* Setup Raycast
* Setup Ilya Birman's layouts, use layout from `macos/` folder (needs guide)
* iCloud — delete all the syncs (needs guide)
* Sudo with TouchID <https://sixcolors.com/post/2020/11/quick-tip-enable-touch-id-for-sudo/>
* Setup karabiner-elements
* Scroll acceleration mouse fix <https://github.com/emreyolcu/discrete-scroll>
* After orbstack installation check docker commands working for regular user
* [Put iTerm and other terminal apps to Developer Tools in Privacy settings](https://x.com/steipete/status/2003925293665337501)
* iTerm2 prefs backed up at `macos/iterm/com.googlecode.iterm2.plist` (not chezmoi-managed).
  Restore: Prefs → General → Preferences → "Load preferences from custom folder" →
  point to `$(chezmoi source-path)/macos/iterm`.
* AltTab settings auto-applied via `run_onchange_after_setup-alt-tab.sh`. Edit that script to tweak.
  After fresh install, set the trigger shortcut once in AltTab GUI (Cmd by default).
* Setup espanso - accessibility settings. Check if
  [memory leak fixed](https://github.com/espanso/espanso/issues/1675).
* If some shit goes with Privacy in MacOS settings, try to remove entry with
  little buttons and launch app once again to go through that hell once more.

### Paid macos apps I use (not in Brewfile)

* Bartender
* BetterSnapTool
* Cleanshot
* ...

## Sidenotes for Linux

* Run `updatedesktopdb` alias after installing `arch-packages` and `chezmoi` things.
* Setup guake-like terminal and shortcuts
* Install/copy windows fonts
* Example of `/etc/fstab` entry for shared NTFS partition:

```bash
$ sudo -i
# mkdir /mnt/Shared
# kate /etc/fstab # CHANGE PARTUUID
PARTUUID="61ffcf10-e472-4c71-8e04-cf57c6463e6b" /mnt/Shared   ntfs3   \
uid=1000,gid=1000,umask=000,nofail,noatime,user,exec 0 0
```

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

* Setup espanso

```shell
sudo setcap "cap_dac_override+p" $(which espanso) # for wayland
espanso service register
espanso start
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
* Enable asterisks on sudo password: `echo 'Defaults pwfeedback' | sudo tee /etc/sudoers.d/20-pwfeedback`
* <https://wiki.cachyos.org/configuration/gaming/#increase-maximum-shader-cache-size>
* Use mvln for compatdata [NTFS mount](https://github.com/ValveSoftware/Proton/wiki/Using-a-NTFS-disk-with-Linux-and-Windows)
* Set kernel params. On 128gb unified RAM, [src](https://github.com/kyuz0/amd-strix-halo-toolboxes?tab=readme-ov-file#62-kernel-parameters-tested-on-fedora-42):

```sh
# /boot/refind_linux.conf
"Boot using default options" "root=PARTUUID=13bbf375-9a9a-45cf-a256-3ea4f77ca6e0 rw nowatchdog zswap.enabled=0 amd_iommu=off transparent_hugepage=always numa_balancing=disable ttm.pages_limit=29360128 ttm.page_pool_size=25165824"
```

* Instructions to use [waystt](https://github.com/sevos/waystt) as Speech-to-Text
  software:

```bash
sudo usermod -a -G input $USER
systemctl --user enable --now ydotool.service
echo '## Give ydotoold access to the uinput device
## Solution by https://github.com/ReimuNotMoe/ydotool/issues/25#issuecomment-535842993
KERNEL=="uinput", GROUP="input", MODE="0660", OPTIONS+="static_node=uinput"
' | sudo tee /etc/udev/rules.d/80-uinput.rules > /dev/null
waystt --download-model
```

* [Playwright installation](https://github.com/microsoft/playwright/issues/2621#issuecomment-2083083392)

```sh
# install playwright and enchant (not in archfile/npmfile)
sudo ln /usr/lib/libicudata.so /usr/lib/libicudata.so.66
sudo ln /usr/lib/libicui18n.so /usr/lib/libicui18n.so.66
sudo ln /usr/lib/libicuuc.so /usr/lib/libicuuc.so.66
sudo ln /usr/lib/libwebp.so /usr/lib/libwebp.so.6
sudo ln /usr/lib/libffi.so /usr/lib/libffi.so.7
```

## Notes on repo

* Repo is using [ejson](https://github.com/Shopify/ejson) with keys.ejson file,
  which is needed to be reencrypted on changes:

```shell
ejson decrypt keys.ejson # or alias - dec
# edit ...
ejson encrypt keys.ejson # or alias - enc
```

## TODO

* Wait for darrylmorley/whatcable
* Test <https://github.com/atuinsh/atuin> as I need shell history
* I need mole setup for iOS - to not clean files managed by chezmoi or install after usage
