# Windows environment setup instruction

## System preparation

- Make sure you are an Administrator user. TODO: instructions for RU/EN +
  switch to user
- Setup drivers
- Layout switch hotkey has to be CTRL+SHIFT
- Enable Developer Mode in Windows Settings (required for symlinks/junctions).
- Enable powershell scripts

## Packages

- Make sure `winget` is installed.
- Install all packages from Wingetfile (TODO: instruction using downloading raw
  file from github.com)
- Add `mise` shims to `PATH` and install packages (TODO: instruction)

## SSH, GPG, KeepassXC

- Make sure OpenSSH Client is working. (TODO: doc. Service? Enabling in windows?)
- Open KeePassXC -> Settings -> SSH Agent -> Enable SSH Agent. Check its working
  via `ssh-add -l`.
- Import and DO NOT FORGET ultimately TRUST gpg key (TODO: full docs)

## ejson

~~~powershell
mkdir "$HOME\.ejson"
# Replace path with actual location of your keys
cmd /c mklink /J "$HOME\.ejson\keys" "C:\Path\To\Your\Decrypted\Keys"
~~~

## Chezmoi

Apply `.dotfiles`:

```bash
chezmoi --version # check things are working
chezmoi cd
chezmoi init git@github.com:Mayurifag/.dotfiles.git --ssh
chezmoi diff # preview
chezmoi apply
```

## TODO

- [ ] Create Wingetfile - with NanaZip, LocalSend, etc.
- [ ] Make automated things from README.md. Minimalistic, idempotent.
- [ ] Other TODOs
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
- [ ] Extract shared aliases from `exact_zsh/40-aliases.zsh` to `.chezmoidata/aliases.yaml`.
- [ ] Create `dot_config/powershell/Microsoft.PowerShell_profile.ps1.tmpl` to auto-generate PowerShell functions from shared alias data.
