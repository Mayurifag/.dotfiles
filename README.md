# Setup environment cheatsheet

That is my dotfiles repository and little cheatsheet on how to setup my systems. It works on MacOS/Windows 11/CachyOS
(Linux). Windows one differs from others, so I put it on [another instruction file](./windows/INSTRUCTION.md).

## Preparation for MacOS

- Update system. Install [homebrew](https://brew.sh/).
- You will need to install homebrew' `zsh` and be sure you switched to it.
- Setup iTerm2 like [guake](https://stackoverflow.com/questions/30850430/iterm2-hide-show-like-guake)

## Preparation for Linux

It mostly implies you should use KDE on Wayland.

- Setup font: use `JetBrains Mono Nerd Font` 11pt for `monospace` and `San Francisco` font for other things.
- Setup CapsLock to change layouts
- KeepassXC with custom browsers requires `Browser integration -> Advanced -> Use a custom browser configuration`.
- Setup ssh agent. Here will be working example for ArchLinux (btw) and Wayland KDE.

```bash
$ systemctl --user enable --now ssh-agent.service

# kate ~/.config/environment.d/ssh_vars.conf
SSH_AUTH_SOCK=${XDG_RUNTIME_DIR}/ssh-agent.socket
```

Make sure `zsh` is default shell: `chsh -s /usr/bin/zsh`. For Yakuake it will also require to setup/choose another
profile, because default one is read-only.

- Add user to input/uinput (for kanata):

```sh
sudo usermod -aG input "$USER"
sudo usermod -aG uinput "$USER"
```

## Installation of environment

- Set `dracula` theme everywhere you can, starting from terminal.
- Go to KeepassXC and check that it works with ssh-agent. `ssh-add -l` has to print key which works with Github.
- Install `mise` using your system manager.

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

- Install packages for all languages and tools: `make mise-packages`
- On Arch/KDE, run `make arch-packages` next, then `chezmoi apply` again.
  The first apply skips the Vicinae hook if Vicinae is not installed. The second apply enables the Linux user services
  and sets KDE shortcuts. Run the Make targets from this repository; `arch-packages` requires `yay` for Archfile packages.

### Vicinae and Grok setup

- Manually install the unmodified Vicinae extensions `@ESHAYAT102/codex` and `@tadassuksteris/prompt-deck`.
  Preferences do not install extensions. There is no extension setup script or Make target.
  From a directory for source checkouts, use the managed Git, Node.js, and npm tools:

```bash
git clone https://github.com/ESHAYAT102/vicinae-codex-extension.git
git -C vicinae-codex-extension checkout --detach 2d772ab114fbbfb7f85cbde09cf4154a1265ed32
npm --prefix vicinae-codex-extension ci
npm --prefix vicinae-codex-extension run build

git clone https://github.com/vicinaehq/extensions.git vicinae-extensions
git -C vicinae-extensions checkout --detach 0e3953058fb787d2a96e5ac0cec462440c07cd07
npm --prefix vicinae-extensions/extensions/prompt-deck ci
npm --prefix vicinae-extensions/extensions/prompt-deck run build
```

- The builds install directly into `${XDG_DATA_HOME:-$HOME/.local/share}/vicinae/extensions/codex` and `prompt-deck`.
  They can overwrite existing local bundles. Keep these directory names: Vicinae derives provider IDs from them.
  Store installs use different IDs and do not receive these managed preferences. Update local builds manually.
- Codex uses an isolated home at `~/.local/share/vicinae/codex`, not the normal Codex home. Authenticate it separately:

```bash
CODEX_HOME="$HOME/.local/share/vicinae/codex" codex login
```

- On Linux, the Vicinae service sets `CODEX_HOME`. For a manual/native launch, set the same variable in its environment.
- Authorize CLIProxyAPI only with an approved account, in a private user terminal, not through an agent or shared log:

```bash
umask 077
cli-proxy-api --config "$HOME/.config/cliproxyapi/config.yaml" --xai-login
```

- Complete OAuth yourself. Never paste tokens into chat or capture authentication output in logs.
  Management is disabled; keep `MANAGEMENT_PASSWORD` unset or empty. Do not enable a management endpoint for login.
- Native PromptDeck preferences already manage endpoint `http://127.0.0.1:18645/v1`, the API key, and model `grok-4.7(low)`.
  Optionally create a native prompt; no custom installer or harness is needed.
- KDE binds Vicinae to `Meta+Space` and Grok to `Meta+Alt+Space`. Grok currently launches the local Quicklink
  `shortcuts:sct-54b9104c5398`, which exists only on the current host. On a fresh host, create a native Quicklink and
  update the single `Exec` command in `dot_local/share/kglobalaccel/executable_grok-chat.desktop`, then apply;
  alternatively, assign a KDE shortcut directly to the desired native command.
- Outside Linux, install a supported native Vicinae build manually; this repo provides no Linux systemd setup there.
  Windows settings come from `AppData/Local/vicinae/config/private_settings.json.tmpl`; macOS settings come from
  `dot_config/vicinae/private_settings.json.tmpl` and render under `~/.config/vicinae/`.
  Start the proxy manually with `MANAGEMENT_PASSWORD` unset or empty:
  `cli-proxy-api --config <home>/.config/cliproxyapi/config.yaml --local-model` (replace `<home>` with your home path).

## Things to do after

- Authenticate GitHub CLI (token stored in OS keyring — same on macOS/Linux):

```bash
gh auth login
# → GitHub.com → SSH → Login with a web browser
```

- Initiate sync on VSCode
- Import and DO NOT FORGET ultimately TRUST gpg key:

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

- Install and configure gitkraken (ssh from system, etc.)
- Setup external disks (router or else)
- Setup Obsidian
- Setup [Browsers.app](https://browsers.software/) as default browser

## Sidenotes for MacOS

- Setup Raycast
- Setup Ilya Birman's layouts, use layout from `macos/` folder (needs guide)
- iCloud — delete all the syncs (needs guide)
- Sudo with TouchID <https://sixcolors.com/post/2020/11/quick-tip-enable-touch-id-for-sudo/>
- Setup karabiner-elements
- Scroll acceleration mouse fix <https://github.com/emreyolcu/discrete-scroll>
- After orbstack installation check docker commands working for regular user
- [Put iTerm and other terminal apps to Developer Tools in Privacy settings](https://x.com/steipete/status/2003925293665337501)
- iTerm2 prefs backed up at `macos/iterm/com.googlecode.iterm2.plist` (not chezmoi-managed). Restore: Prefs → General →
  Preferences → "Load preferences from custom folder" → point to `$(chezmoi source-path)/macos/iterm`.
- AltTab settings auto-applied via `run_onchange_after_setup-alt-tab.sh`. Edit that script to tweak. After fresh
  install, set the trigger shortcut once in AltTab GUI (Cmd by default).
- Setup espanso - accessibility settings. Check if [memory leak fixed](https://github.com/espanso/espanso/issues/1675).
- If some shit goes with Privacy in MacOS settings, try to remove entry with little buttons and launch app once again to
  go through that hell once more.

### Paid macos apps I use (not in Brewfile)

- BetterSnapTool
- Cleanshot
- ...

## Sidenotes for Linux

- Run `updatedesktopdb` alias after installing `arch-packages` and `chezmoi` things.
- Setup guake-like terminal and shortcuts
- Install/copy windows fonts
- Example of `/etc/fstab` entry for shared NTFS partition:

```bash
$ sudo -i
# mkdir /mnt/Shared
# kate /etc/fstab # CHANGE PARTUUID
PARTUUID="61ffcf10-e472-4c71-8e04-cf57c6463e6b" /mnt/Shared   ntfs3   \
uid=1000,gid=1000,umask=000,nofail,noatime,user,exec 0 0
```

- Setup
  [Wi-fi regulatory domain](https://wiki.cachyos.org/configuration/post_install_setup/#configure-wi-fi-regulatory-domain)
  to South Korea:

```txt
# /etc/conf.d/wireless-regdom
WIRELESS_REGDOM="KR"
```

- Prevent updating of gitkraken:

```txt
# /etc/pacman.conf
...
IgnorePkg = gitkraken
```

- Enable native overlay diff engine to speed up building images in docker (info from ArchWiki):

```bash
$ kate /etc/modprobe.d/disable-overlay-redirect-dir.conf
options overlay metacopy=off redirect_dir=off
$ modprobe -r overlay
$ modprobe overlay
```

- Activate docker socket and group

```bash
sudo systemctl enable --now docker.service
sudo groupadd docker # Check or create group docker
sudo gpasswd -a $USER docker
docker info # run docker info and check that Native Overlay Diff is true
```

- Setup espanso

```shell
sudo setcap "cap_dac_override+p" $(which espanso) # for wayland
espanso service register
espanso start
```

- Setup bluetooth (maybe
  [dualboot](https://konfekt.github.io/blog/2023/05/21/bluetooth-sync-keys-windows-linux-dualboot#low-energy-devices))
- Setup shortcuts:

```conf
Dolphin: Alt+E # a-la macos
Spectacle: Rectangular region on Alt+1 (Alt+!) # screenshot tool, I dont think I need other functions
Yakuake: Alt+`, Ctrl+` # terminal. Alt+` for a-la macos
Krunner: Meta+Space
```

- Clean system time to time: `sudo systemctl enable --now yaycache.timer`
- Enable asterisks on sudo password: `echo 'Defaults pwfeedback' | sudo tee /etc/sudoers.d/20-pwfeedback`
- <https://wiki.cachyos.org/configuration/gaming/#increase-maximum-shader-cache-size>
- Use mvln for compatdata
  [NTFS mount](https://github.com/ValveSoftware/Proton/wiki/Using-a-NTFS-disk-with-Linux-and-Windows)
- Set kernel params. On 128gb unified RAM,
  [src](https://github.com/kyuz0/amd-strix-halo-toolboxes?tab=readme-ov-file#62-kernel-parameters-tested-on-fedora-42):

```sh
# /boot/refind_linux.conf
"Boot using default options" "root=PARTUUID=13bbf375-9a9a-45cf-a256-3ea4f77ca6e0 rw nowatchdog zswap.enabled=0 amd_iommu=off transparent_hugepage=always numa_balancing=disable ttm.pages_limit=29360128"
```

- Instructions to use [waystt](https://github.com/sevos/waystt) as Speech-to-Text software:

```bash
sudo usermod -a -G input $USER
systemctl --user enable --now ydotool.service
echo '## Give ydotoold access to the uinput device
## Solution by https://github.com/ReimuNotMoe/ydotool/issues/25#issuecomment-535842993
KERNEL=="uinput", GROUP="input", MODE="0660", OPTIONS+="static_node=uinput"
' | sudo tee /etc/udev/rules.d/80-uinput.rules > /dev/null
waystt --download-model
```

- [Playwright installation](https://github.com/microsoft/playwright/issues/2621#issuecomment-2083083392)

```sh
# install playwright and enchant (not in archfile/npmfile)
sudo ln /usr/lib/libicudata.so /usr/lib/libicudata.so.66
sudo ln /usr/lib/libicui18n.so /usr/lib/libicui18n.so.66
sudo ln /usr/lib/libicuuc.so /usr/lib/libicuuc.so.66
sudo ln /usr/lib/libwebp.so /usr/lib/libwebp.so.6
sudo ln /usr/lib/libffi.so /usr/lib/libffi.so.7
```

## Notes on repo

- Repo is using [ejson](https://github.com/Shopify/ejson) with keys.ejson file. With the global git hooks below, you
  just edit and commit; the hook encrypts the staged blob automatically. Manual escape hatch: `dec` / `enc` aliases.

### Global secret hooks

`core.hooksPath = ~/.config/git/hooks` is set, so these run for every repo:

- **pre-commit** — for each staged file matched by a provider (`*.ejson`, or any path with `filter=git-crypt` in
  `.gitattributes`), the staged blob is encrypted in place via `git update-index --cacheinfo`. The working tree is never
  touched, so a failed/aborted commit cannot leave you with an encrypted working copy. Plaintext under `git-crypt` scope
  aborts with a hint to unlock.
- **pre-push** — walks the commits in the push range, inspects only blobs matched by a provider, and refuses the push if
  any blob is still plaintext. Belt-and-suspenders for `--no-verify` commits or rebase mistakes.
- **post-checkout** — auto-runs `git-sync --auto` (fetch/prune/ff/trim) on inferred cleanup branches with a clean working
  tree. Cleanup branches are remote HEAD targets, or tracking branches that already have other local branches merged in.
  Remote-backed local branches are protected while their upstream refs still exist.

All three chain to a repo-local `.githooks/<hook>` or `.git/hooks/<hook>` if present, so per-repo hook frameworks (e.g.
`pre-commit`, lefthook) keep working.

Add a new provider by adding one `case` arm to each of `secrets_classify_paths`, `secrets_blob_is_plaintext`, and
`secrets_encrypt_file` in `~/.config/git/hooks/_secrets-lib`.

## TODO

- Test <https://github.com/atuinsh/atuin> as I need shell history
