# Windows Setup

## Prerequisites

* Windows 11
* Git installed manually first (not yet in PATH — download from [git-scm.com](https://git-scm.com/))
* Clone this repo: `git clone git@github.com:Mayurifag/.dotfiles.git`
* Allow scripts to run if needed:

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## Script Sequence

Scripts 1–2 require an **elevated PowerShell session** (Run as Administrator).

1. **install.ps1** (Admin) — installs all packages from Wingetfile, sets up mise/Go/ejson toolchain

```powershell
.\install.ps1
```

2. **setup-ssh-gpg.ps1** (Admin) — enables SSH agent service, prints KeePassXC and GPG setup instructions

```powershell
.\setup-ssh-gpg.ps1
```

> Manual steps required here — see [Manual Steps](#manual-steps) below

3. **setup-shell.ps1** (no Admin) — runs `chezmoi apply`, creates espanso NTFS junction

```powershell
.\setup-shell.ps1
```

4. **setup-terminal.ps1** (no Admin) — Dracula theme, JetBrainsMono Nerd Font, Win+backtick quake mode

```powershell
.\setup-terminal.ps1
```

5. **defaults.ps1** (no Admin, optional) — dark mode, file extensions visible, taskbar left-aligned

```powershell
.\defaults.ps1
```

## Manual Steps

### Before install.ps1

* Set execution policy if scripts are blocked (see Prerequisites above)

### Between setup-ssh-gpg.ps1 and setup-shell.ps1

* KeePassXC → Tools → Settings → SSH Agent → enable **Use OpenSSH for Windows**
* Right-click your KeePassXC entry → SSH Agent → **Add to Agent**
* Verify key loaded:

```powershell
& "C:\Windows\System32\OpenSSH\ssh-add.exe" -l
```

* Import GPG key and trust it:

```
IMPORT: gpg --import private-key.asc
Check: gpg --list-secret-keys
Trust the imported key:

gpg --edit-key [key_id]
gpg> trust
  5 = I trust ultimately
Do you really want to set this key to ultimate trust? (y/N) y
gpg> quit
```

* Run chezmoi init (requires SSH key loaded above):

```powershell
chezmoi init git@github.com:Mayurifag/.dotfiles.git
```

### After all scripts

* Copy ejson decryption key to `%USERPROFILE%\.ejson\keys\<key-hash>`

## Nice-to-have Apps

Not installed by install.ps1 — optional extras.

```powershell
winget install GitKraken.GitKraken   # git GUI
```

* **Browsers.app** — the winget ID may vary; run `winget search Browsers` to find the correct ID before installing
