# Windows environment setup instruction

## System preparation

- Make sure you are an Administrator user. TODO: instructions for RU/EN +
  switch to user
- Setup drivers
- Layout switch hotkey has to be CTRL+SHIFT
- Setup external disks (NAS/router/...)
- Make sure `winget` is installed.

~~~powershell
Invoke-RestMethod -Uri "https://raw.githubusercontent.com/Mayurifag/.dotfiles/main/windows/init.ps1" | Invoke-Expression
~~~

## ejson

~~~powershell
mkdir "$HOME\.ejson"
New-Item -ItemType SymbolicLink -Path "$HOME\.ejson" -Target "C:\Path\To\Your\Decrypted\Keys"
~~~

## Chezmoi

- Open KeePassXC -> Settings -> SSH Agent -> Enable SSH Agent. Check its working
  via `ssh-add -l`.
- Apply `.dotfiles`:

~~~powershell
chezmoi --version # check chezmoi is installed
chezmoi cd
chezmoi init git@github.com:Mayurifag/.dotfiles.git --ssh
chezmoi diff # preview
chezmoi apply
~~~

## Other

- Import and DO NOT FORGET ultimately TRUST gpg key (TODO: full docs)
- Setup Obsidian
- Setup [get-shit-done](https://github.com/gsd-build/get-shit-done)
- Setup [Browsers.app](https://browsers.software/) as default browser
- Make [steam silent](https://leo3418.github.io/2023/07/15/minimize-steam-for-game-shortcuts.html)
  (requires script)

## TODO

- [ ] Powershell profile
- [ ] Even though PowerShell profile will have mise, install it also for bash in windows for claude
- [ ] Setup VSCode - sync settings
- [ ] Setup browser - addons settings and keepassxc config if needed
- [ ] Setup gitkraken with activation (requires full path)
- [ ] Setup PowerToys - only with tools I use
- [ ] Make sure espanso working
- [ ] Autohotkey cfg: copied onto repo and script to Startup to launch
- [ ] Migrate to kanata/komokana. See whats not needed in espanso
- [ ] Shared aliases between zsh and pwsh setups
- [ ] Script to configure Windows Terminal:
  - [ ] Set JetBrainsMono as default font face (make sure right name is selected).
  - [ ] Setup Global Summon (Quake Mode) shortcut CTRL+~ and CTRL+ё.
  - [ ] Set Dracula color scheme.
  - [ ] Default profile to PowerShell latest version.
  - [ ] Quake mode has to toggle focus mode so tabs will be seen
- [ ] Extract shared aliases from `exact_zsh/40-aliases.zsh` to `.chezmoidata/aliases.yaml`.
- [ ] Create `dot_config/powershell/Microsoft.PowerShell_profile.ps1.tmpl` to auto-generate PowerShell functions from shared alias data.
- [ ] Wait for `mise` to support `winget` backend and migrate to it.
  <https://github.com/jdx/mise/discussions/8311>
