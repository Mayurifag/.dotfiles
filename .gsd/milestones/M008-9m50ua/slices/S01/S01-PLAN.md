# S01: Windows Terminal Settings via Symlink

**Goal:** Chezmoi-manage a complete Windows Terminal settings.json and deploy it via symlink so WT is fully configured after `chezmoi apply`.
**Demo:** On Windows, `chezmoi apply` deploys the settings file and creates the symlink; opening WT shows JetBrainsMono font, Dracula theme, pwsh as default; Ctrl+` toggles quake mode; WT starts on login.

## Must-Haves

- `dot_config/windows-terminal/settings.json` exists with: `startOnUserLogin: true`, JetBrainsMono Nerd Font, Dracula color scheme, pwsh default profile, globalSummon actions for Ctrl+` and Ctrl+ё
- `run_once_setup-windows-terminal.ps1` creates symlink from WT AppData path to `~/.config/windows-terminal/settings.json`, with Developer Mode check, backup of existing file, and idempotent behavior
- `.chezmoiignore` gates `.config/windows-terminal/` to Windows-only (excluded on non-Windows)
- `JetBrainsMono Nerd Font` is listed in `install/Wingetfile`
- `chezmoi apply --dry-run` on Linux produces zero errors

## Verification

- `grep -c 'startOnUserLogin' dot_config/windows-terminal/settings.json` returns 1
- `grep -c 'JetBrainsMono' dot_config/windows-terminal/settings.json` returns 1
- `grep -c 'Dracula' dot_config/windows-terminal/settings.json` returns ≥1
- `grep -c 'globalSummon' dot_config/windows-terminal/settings.json` returns ≥1
- `grep 'windows-terminal' .chezmoiignore` shows the gate
- `grep 'JetBrainsMono' install/Wingetfile` shows the font entry
- PS syntax check passes on the run_once script
- `chezmoi apply --dry-run --force 2>&1 | grep -i error | grep -v 'ejson\|decrypt' | wc -l` returns 0 (on Linux)

## Tasks

- [x] **T01: Author WT settings.json + run_once symlink script + Wingetfile entry** `est:25m`
  - Why: This is the core deliverable — the settings file with all WT configuration and the script to wire it into WT's path
  - Files: `dot_config/windows-terminal/settings.json`, `run_once_setup-windows-terminal.ps1`, `install/Wingetfile`, `.chezmoiignore`
  - Do:
    1. Create `dot_config/windows-terminal/settings.json` with complete WT config:
       - `"$help"` and `"$schema"` headers
       - `"defaultProfile"` set to pwsh (use `"commandline": "pwsh.exe"` in profile list to let WT resolve GUID)
       - `"startOnUserLogin": true`
       - `"profiles.defaults"` with `"font.face": "JetBrainsMono Nerd Font"`, `"colorScheme": "Dracula"`
       - Dracula color scheme in `"schemes"` array (translate hex values from official Dracula: background #282A36, foreground #F8F8F2, etc.)
       - `"actions"` with two `globalSummon` entries: one for `ctrl+\`` (backtick/tilde key) and one for `ctrl+ё` (Russian layout equivalent) — both targeting `"name": "_quake"`, `"desktop": "toCurrent"`, `"toggleFocusMode": false` (so tabs stay visible)
       - PowerShell 7 profile entry with `"name": "PowerShell"`, `"commandline": "pwsh.exe"`, `"hidden": false`
    2. Create `run_once_setup-windows-terminal.ps1`:
       - Windows guard: `if ($env:OS -ne 'Windows_NT') { exit 0 }`
       - Developer Mode check: read `HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock\AllowDevelopmentWithoutDevLicense`; if not 1, print warning with instructions and exit 1
       - Define target: `$wtSettings = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"`
       - Define source: `$chezmoiSettings = "$env:USERPROFILE\.config\windows-terminal\settings.json"`
       - If `$wtSettings` is already a symlink pointing to `$chezmoiSettings`, exit 0 (idempotent)
       - If `$wtSettings` exists (regular file), rename to `settings.json.bak`
       - Create parent directory if missing
       - `cmd /c mklink "$wtSettings" "$chezmoiSettings"` (or `New-Item -ItemType SymbolicLink`)
       - Verify symlink was created
    3. Add `DEVCOM.JetBrainsMonoNerdFont` to `install/Wingetfile` (alphabetical order)
    4. Add `.config/windows-terminal/` to `.chezmoiignore` in the `ne windows` block (excluded on non-Windows platforms)
  - Verify:
    - `grep -c 'startOnUserLogin' dot_config/windows-terminal/settings.json` → 1
    - `grep -c 'JetBrainsMono' dot_config/windows-terminal/settings.json` → 1
    - `grep -c 'Dracula' dot_config/windows-terminal/settings.json` → ≥1
    - `grep -c 'globalSummon' dot_config/windows-terminal/settings.json` → ≥1
    - `grep 'JetBrainsMono' install/Wingetfile` → match
    - PS syntax check on run_once script passes
    - `chezmoi apply --dry-run --force 2>&1 | grep -i error | grep -v 'ejson\|decrypt' | wc -l` → 0
  - Done when: all verification commands pass; settings.json is valid JSON; run_once script has PS-valid syntax

## Files Likely Touched

- `dot_config/windows-terminal/settings.json` (new)
- `run_once_setup-windows-terminal.ps1` (new)
- `install/Wingetfile`
- `.chezmoiignore`
