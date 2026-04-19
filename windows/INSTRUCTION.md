# Windows environment setup instruction

## System preparation

- Make sure you are an Administrator user. TODO: instructions for RU/EN +
  switch to user
- Setup drivers
- Layout switch hotkey has to be CTRL+SHIFT
- Setup external disks (NAS/router/...)
- Setup OpenCloud
- Setup KeepassXC
- Activate all [tweaks](./tweaks/)
- Make sure `winget` is installed

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

Symlink the ejson keys directory and set `EJSON_KEYDIR` (ejson defaults to
`/opt/ejson/keys` on all platforms, which doesn't exist on Windows):

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

Authenticate GitHub CLI (token stored in Windows Credential Manager):

~~~powershell
gh auth login
# → GitHub.com → SSH → Login with a web browser
~~~

## Other

- Import and DO NOT FORGET ultimately TRUST gpg key (TODO: full docs)
- Setup espanso (it will write itself into PATH)
- Setup Obsidian
- Setup [Browsers.app](https://browsers.software/) as default browser
- Make [steam silent](https://leo3418.github.io/2023/07/15/minimize-steam-for-game-shortcuts.html)
  (requires script)
- [Enable emoji flags (chrome/...)](https://github.com/tuannvbg/unicode-flags-for-windows)
- Setup Helium with profile sync

## TODO

- [ ] Setup VSCode - sync settings
- [ ] Setup gitkraken with activation (requires full path) and configure (system
  ssh, etc.)
- [ ] Everything with settings for powertoys (+plugin) and for windhawk
- [ ] Setup PowerToys - only with tools I use
- [ ] Altsnap
- [ ] JPEGView - setup with cfg from Opencloud / migrate here
- [ ] LocalSend - desktop shortcut from Opencloud
- [ ] ShareX - autostart
- [ ] WinAero - not sure what exactly to tweak. Hidden drives hiding?
- [ ] simplewall - but needs to have pareto principle setup
- [ ] Local LLM?
- [ ] Wait for `mise` to support `winget` backend and migrate to it.
  <https://github.com/jdx/mise/discussions/8311>
