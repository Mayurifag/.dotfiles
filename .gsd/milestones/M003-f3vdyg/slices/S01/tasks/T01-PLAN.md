---
estimated_steps: 3
estimated_files: 1
---

# T01: Add GitKraken section to aliases_ps1

**Slice:** S01 — Add gk function and g alias to aliases_ps1
**Milestone:** M003-f3vdyg

## Description

Append a `## GitKraken` section to the end of `.chezmoitemplates/aliases_ps1` containing a `gk` PowerShell function and a `g` shorthand alias. The function globs the newest GitKraken versioned install directory, validates preconditions (GitKraken installed, inside a git repo), resolves the git root to a Windows path, and launches GitKraken via `Start-Process` (non-blocking).

## Steps

1. Open `.chezmoitemplates/aliases_ps1` and locate the end of the file (after `## grep` section)
2. Append the `## GitKraken` section with the `gk` function body:
   - `Get-Item "$env:LOCALAPPDATA\gitkraken\app-*\gitkraken.exe" -ErrorAction SilentlyContinue | Sort-Object Name -Descending | Select-Object -First 1 -ExpandProperty FullName` to find the exe
   - Guard: `if (-not $gkExe) { Write-Warning "GitKraken not found"; return }`
   - `git rev-parse --show-toplevel 2>$null` to get git root
   - Guard: `if (-not $root) { Write-Warning "Not a git repository"; return }`
   - `(Resolve-Path $root).Path` to convert to Windows path
   - `Start-Process -FilePath $gkExe -ArgumentList "--new-window", "-p", $root` to launch
3. Add `Set-Alias -Name g -Value gk` after the function

## Must-Haves

- [ ] `gk` function uses `Get-Item` with `-ErrorAction SilentlyContinue` for safe glob
- [ ] Sort by Name descending to pick newest version
- [ ] Guard clause for missing GitKraken
- [ ] Guard clause for non-git directory
- [ ] `Resolve-Path` for Windows path conversion
- [ ] `Start-Process` for non-blocking launch (no `-Wait`, no `-NoNewWindow`)
- [ ] Uses `-p` flag (matching zsh alias) not `--path`
- [ ] `Set-Alias -Name g -Value gk` shorthand

## Verification

- `grep -c 'function gk' .chezmoitemplates/aliases_ps1` outputs `1`
- `grep -c "Set-Alias -Name g -Value gk" .chezmoitemplates/aliases_ps1` outputs `1`
- `grep 'Start-Process' .chezmoitemplates/aliases_ps1` shows the launch line with `-p` flag

## Inputs

- `.chezmoitemplates/aliases_ps1` — existing PS aliases fragment; append after `## grep` section
- Research recommendation in `M003-f3vdyg-RESEARCH.md` — provides the exact implementation

## Expected Output

- `.chezmoitemplates/aliases_ps1` — updated with `## GitKraken` section containing `gk` function and `g` alias
