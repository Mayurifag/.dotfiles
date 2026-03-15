---
estimated_steps: 4
estimated_files: 4
---

# T01: Author WT settings.json + run_once symlink script + Wingetfile entry

**Slice:** S01 — Windows Terminal Settings via Symlink
**Milestone:** M008-9m50ua

## Description

Create the complete Windows Terminal settings.json at a chezmoi-managed path, author the run_once PowerShell script that symlinks it into WT's AppData location, add JetBrainsMono Nerd Font to Wingetfile, and gate the new directory in .chezmoiignore.

## Steps

1. Create `dot_config/windows-terminal/settings.json` with all WT configuration: pwsh default profile, JetBrainsMono Nerd Font, Dracula color scheme, `startOnUserLogin: true`, globalSummon actions for Ctrl+` and Ctrl+ё (quake mode, tabs visible), standard WT profiles.
2. Create `run_once_setup-windows-terminal.ps1` with Windows guard, Developer Mode check, backup of existing settings.json, symlink creation via `cmd /c mklink`, and idempotent behavior (skip if symlink already correct).
3. Add `DEVCOM.JetBrainsMonoNerdFont` to `install/Wingetfile` in alphabetical order.
4. Add `.config/windows-terminal/` to the `ne windows` block in `.chezmoiignore` (excluded on non-Windows).

## Must-Haves

- [ ] `dot_config/windows-terminal/settings.json` contains `startOnUserLogin`, JetBrainsMono font, Dracula scheme, pwsh default, globalSummon for Ctrl+`/Ctrl+ё
- [ ] `run_once_setup-windows-terminal.ps1` creates symlink, checks Developer Mode, backs up existing file, is idempotent
- [ ] `DEVCOM.JetBrainsMonoNerdFont` in Wingetfile
- [ ] `.config/windows-terminal/` gated in .chezmoiignore
- [ ] `chezmoi apply --dry-run` on Linux has zero new errors

## Verification

- `node -e "JSON.parse(require('fs').readFileSync('dot_config/windows-terminal/settings.json','utf8'))" && echo VALID` → VALID (valid JSON)
- `grep -c 'startOnUserLogin' dot_config/windows-terminal/settings.json` → 1
- `grep -c 'JetBrainsMono' dot_config/windows-terminal/settings.json` → ≥1
- `grep -c 'Dracula' dot_config/windows-terminal/settings.json` → ≥1
- `grep -c 'globalSummon' dot_config/windows-terminal/settings.json` → ≥1
- `grep 'JetBrainsMonoNerdFont' install/Wingetfile` → match
- `grep 'windows-terminal' .chezmoiignore` → match
- PS syntax check passes on run_once script
- `chezmoi apply --dry-run --force 2>&1 | grep -i error | grep -v 'ejson|decrypt' | wc -l` → 0

## Inputs

- `dot_local/share/konsole/klorax.dracula-transparent.colorscheme` — Dracula color reference values
- `run_once_setup-kanata-windows.ps1` — established pattern for run_once PS scripts
- `.chezmoiignore` — current gate structure
- `install/Wingetfile` — current package list

## Expected Output

- `dot_config/windows-terminal/settings.json` — complete WT settings file (~100-150 lines)
- `run_once_setup-windows-terminal.ps1` — symlink creation script (~40-50 lines)
- `install/Wingetfile` — with JetBrainsMono entry added
- `.chezmoiignore` — with `.config/windows-terminal/` gate added
