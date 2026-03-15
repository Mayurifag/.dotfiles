# S01: UAT — Windows Bootstrap Flow

**Slice:** S01 — Complete init.ps1 + preflight.ps1 + INSTRUCTION.md
**Milestone:** M007

## Test Environment

- Fresh Windows machine (or one where you can safely re-run init.ps1)
- Administrator PowerShell for init.ps1
- Regular PowerShell (new terminal) for preflight.ps1
- KeePassXC with SSH key entry
- ejson keys accessible at `D:\OpenCloud\Personal\Software\dotfiles\ejson\keys`

## Test Script

### 1. init.ps1 (Admin PowerShell)

Run:
```powershell
Invoke-RestMethod -Uri "https://raw.githubusercontent.com/Mayurifag/.dotfiles/master/windows/init.ps1" | Invoke-Expression
```

**Verify:**
- [ ] Script runs through all 14 steps without fatal errors
- [ ] Winget installs all apps (including GnuWin32.Make)
- [ ] mise install completes and reports installed runtimes
- [ ] Language packages install (npm, cargo, go, gem, uv outputs visible)
- [ ] Post-install instructions are printed clearly at the end
- [ ] SSH key instruction mentions KeePassXC
- [ ] ejson key symlink command is printed with correct path
- [ ] preflight.ps1 download command is printed

### 2. Manual steps

- [ ] Set up SSH key via KeePassXC SSH Agent
- [ ] Verify with `ssh-add -l` — at least one key shown
- [ ] Create ejson key symlink: `cmd /c mklink /D "%USERPROFILE%\.ejson\keys" "D:\OpenCloud\Personal\Software\dotfiles\ejson\keys"`

### 3. preflight.ps1 (New Terminal, regular user)

Open a **new** PowerShell terminal and run:
```powershell
Invoke-RestMethod -Uri "https://raw.githubusercontent.com/Mayurifag/.dotfiles/master/windows/preflight.ps1" | Invoke-Expression
```

**Verify:**
- [ ] All 6 checks show PASS (green)
- [ ] Script prompts to run chezmoi init
- [ ] After pressing Enter, `chezmoi init` runs and succeeds
- [ ] Post-init guidance shows `chezmoi diff` and `chezmoi apply`

### 4. Negative test (optional)

Without SSH key or ejson:
- [ ] preflight.ps1 shows FAIL for missing items with actionable fix hints
- [ ] Script exits with error (does not offer chezmoi init)
