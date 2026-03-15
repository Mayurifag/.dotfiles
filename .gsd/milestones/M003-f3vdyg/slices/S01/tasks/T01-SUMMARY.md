---
id: T01
parent: S01
milestone: M003-f3vdyg
provides:
  - GitKraken gk function and g alias in .chezmoitemplates/aliases_ps1
key_files:
  - .chezmoitemplates/aliases_ps1
key_decisions:
  - Used Get-Item glob with Sort-Object Name -Descending to pick newest versioned install dir
  - Used -p flag (not --path) to match confirmed-working zsh alias
  - Start-Process without -Wait or -NoNewWindow for non-blocking launch
patterns_established:
  - Guard clauses with Write-Warning + early return for missing tool and non-git-repo
observability_surfaces:
  - none
duration: 5m
verification_result: passed
completed_at: 2026-03-15
blocker_discovered: false
---

# T01: Add GitKraken section to aliases_ps1

**Appended `## GitKraken` section to `.chezmoitemplates/aliases_ps1` with `gk` function and `Set-Alias -Name g -Value gk`.**

## What Happened

Appended the `## GitKraken` section after the existing `## grep` section at the bottom of `.chezmoitemplates/aliases_ps1`. The `gk` function globs the newest GitKraken versioned install directory via `Get-Item "$env:LOCALAPPDATA\gitkraken\app-*\gitkraken.exe"`, sorts by Name descending, guards for missing exe and non-git-repo with `Write-Warning` + `return`, resolves the git root with `Resolve-Path`, and launches via `Start-Process` (non-blocking). A `Set-Alias -Name g -Value gk` shorthand follows.

## Verification

- `grep -c 'function gk' .chezmoitemplates/aliases_ps1` → `1` ✓
- `grep -c "Set-Alias -Name g -Value gk" .chezmoitemplates/aliases_ps1` → `1` ✓
- `grep 'Start-Process' .chezmoitemplates/aliases_ps1` → shows line with `-p` flag ✓
- `chezmoi execute-template < Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl | grep -q 'function gk'` → `PASS` ✓
- `chezmoi apply --dry-run --force 2>&1 | grep -i error | grep -v 'ejson\|decrypt' | wc -l` → `0` ✓

## Diagnostics

```sh
# Confirm gk function is present in the template file
grep -A 12 '## GitKraken' .chezmoitemplates/aliases_ps1

# Confirm function renders in the PS profile
chezmoi execute-template < Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl 2>&1 | grep -A 10 'function gk'

# Confirm alias renders in the PS profile
chezmoi execute-template < Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl 2>&1 | grep 'Set-Alias -Name g -Value gk'

# Confirm dry-run is clean (non-ejson errors only)
chezmoi apply --dry-run --force 2>&1 | grep -i error | grep -v 'ejson\|decrypt'
```

## Deviations

none

## Known Issues

none

## Files Created/Modified

- `.chezmoitemplates/aliases_ps1` — appended `## GitKraken` section with `gk` function and `g` alias
