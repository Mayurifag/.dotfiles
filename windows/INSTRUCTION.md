# Windows environment setup instruction

## System preparation

- Make sure you are an Administrator user. TODO: instructions for RU/EN +
  switch to user
- Setup drivers
- Layout switch hotkey has to be CTRL+SHIFT
- Setup external disks (NAS/router/...)
- Make sure `winget` is installed.

Run `init.ps1` as Administrator — installs winget apps, mise runtimes, and
language packages:

~~~powershell
Invoke-RestMethod -Uri "https://raw.githubusercontent.com/Mayurifag/.dotfiles/master/windows/init.ps1" | Invoke-Expression
~~~

## Manual setup (after init.ps1)

### SSH Key

Open KeePassXC → Settings → SSH Agent → Enable SSH Agent integration. Then
enable the SSH key entry in your KeePass database for agent use. Verify:

~~~powershell
ssh-add -l
~~~

### EJSON Keys

Symlink the ejson keys directory and set `EJSON_KEYDIR` (ejson defaults to `/opt/ejson/keys` on all platforms, which doesn't exist on Windows):

~~~powershell
New-Item -ItemType Directory -Force "$env:USERPROFILE\.ejson" | Out-Null; cmd /c mklink /D "%USERPROFILE%\.ejson\keys" "D:\OpenCloud\Personal\Software\dotfiles\ejson\keys"
[System.Environment]::SetEnvironmentVariable("EJSON_KEYDIR", "$env:USERPROFILE\.ejson\keys", "User")
~~~

## Preflight & chezmoi init

Open a **new terminal** (not the one init.ps1 ran in) and run:

~~~powershell
Invoke-RestMethod -Uri "https://raw.githubusercontent.com/Mayurifag/.dotfiles/master/windows/preflight.ps1" | Invoke-Expression
~~~

This checks that git, bash, chezmoi, ejson, ejson keys, and SSH key are all
ready, then runs `chezmoi init git@github.com:Mayurifag/.dotfiles.git --ssh`.

## After chezmoi init

~~~powershell
chezmoi diff    # preview changes
chezmoi apply   # apply dotfiles
mise install    # install any tools added by chezmoi config
~~~

## Other

- Import and DO NOT FORGET ultimately TRUST gpg key (TODO: full docs)
- Setup Obsidian
- Setup [Browsers.app](https://browsers.software/) as default browser
- Make [steam silent](https://leo3418.github.io/2023/07/15/minimize-steam-for-game-shortcuts.html)
  (requires script)

## TODO

- [ ] Setup VSCode - sync settings
- [ ] Setup browser - addons settings and keepassxc config if needed
- [ ] Setup gitkraken with activation (requires full path)
- [ ] Setup PowerToys - only with tools I use
- [ ] Make sure espanso working
- [ ] Autohotkey cfg: copied onto repo and script to Startup to launch
- [ ] Script to configure Windows Terminal:
  - [ ] Set JetBrainsMono as default font face (make sure right name is selected).
  - [ ] Setup Global Summon (Quake Mode) shortcut CTRL+~ and CTRL+ё.
  - [ ] Set Dracula color scheme.
  - [ ] Default profile to PowerShell latest version.
  - [ ] Quake mode has to toggle focus mode so tabs will be see
- [ ] Wait for `mise` to support `winget` backend and migrate to it.
  <https://github.com/jdx/mise/discussions/8311>
