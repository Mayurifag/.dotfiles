---
id: S01
parent: M003-f3vdyg
milestone: M003-f3vdyg
provides:
  - GitKraken gk function and g alias in .chezmoitemplates/aliases_ps1
requires: []
affects: []
key_files:
  - .chezmoitemplates/aliases_ps1
key_decisions:
  - Used Get-Item glob with Sort-Object Name -Descending to pick newest versioned install dir
  - Used -p flag (not --path) to match confirmed-working zsh alias
  - Start-Process without -Wait or -NoNewWindow for non-blocking launch
  - Guard clauses with Write-Warning + early return for missing tool and non-git-repo
patterns_established:
  - Guard clauses with Write-Warning + early return for missing external tool and non-git-repo
observability_surfaces:
  - "grep -A 12 '## GitKraken' .chezmoitemplates/aliases_ps1"
  - "chezmoi execute-template < Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl 2>&1 | grep 'function gk'"
  - "chezmoi apply --dry-run --force 2>&1 | grep -i error | grep -v 'ejson|decrypt'"
drill_down_paths:
  - .gsd/milestones/M003-f3vdyg/slices/S01/tasks/T01-SUMMARY.md
  - .gsd/milestones/M003-f3vdyg/slices/S01/tasks/T02-SUMMARY.md
duration: ~10m (T01: 5m, T02: <1m)
verification_result: passed
completed_at: 2026-03-15
---

# S01: Add gk function and g alias to aliases_ps1

**Appended a `## GitKraken` section to `.chezmoitemplates/aliases_ps1` containing a `gk` function and `Set-Alias -Name g -Value gk`; `chezmoi execute-template` renders both in the PS profile with zero dry-run errors.**

## What Happened

T01 appended a `## GitKraken` section after the existing `## grep` section at the bottom of `.chezmoitemplates/aliases_ps1`. The `gk` function:

1. Globs `$env:LOCALAPPDATA\gitkraken\app-*\gitkraken.exe` via `Get-Item … -ErrorAction SilentlyContinue`, sorts by Name descending, takes the first result — picks the newest versioned install dir automatically.
2. Guards: if no exe found, `Write-Warning "GitKraken not found"` + `return`.
3. Captures git root via `git rev-parse --show-toplevel 2>$null`; guards: if empty, `Write-Warning "Not a git repository"` + `return`.
4. Resolves the path with `Resolve-Path` to normalise any forward-slash output from git.
5. Launches via `Start-Process -FilePath $gkExe -ArgumentList "--new-window", "-p", $root` — non-blocking, returns the prompt immediately.

`Set-Alias -Name g -Value gk` follows on the next line.

T02 verified the rendered PS profile and confirmed `chezmoi apply --dry-run` is clean — no additional fixes were needed.

## Verification

| Check | Command | Result |
|---|---|---|
| Exactly one `function gk` in template | `grep -c 'function gk' .chezmoitemplates/aliases_ps1` | 1 ✓ |
| Exactly one alias line | `grep -c "Set-Alias -Name g -Value gk" .chezmoitemplates/aliases_ps1` | 1 ✓ |
| `-p` flag present | `grep 'Start-Process' .chezmoitemplates/aliases_ps1` | line shows `-p` ✓ |
| `function gk` in rendered PS profile | `chezmoi execute-template < Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl \| grep -q 'function gk'` | PASS ✓ |
| `Set-Alias -Name g -Value gk` in rendered PS profile | `chezmoi execute-template < Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl \| grep -q 'Set-Alias -Name g -Value gk'` | PASS ✓ |
| No new errors from dry-run | `chezmoi apply --dry-run --force 2>&1 \| grep -i error \| grep -v 'ejson\|decrypt' \| wc -l` | 0 ✓ |

## Deviations

none

## Known Limitations

- Integration testing (actually launching GitKraken) requires Windows + a GitKraken install — out of scope for Linux CI. Manual verification on Windows is required after the next `chezmoi apply`.

## Follow-ups

- Manual smoke test on Windows: open a git repo directory in PowerShell, run `gk` and confirm GitKraken opens the project.
- Optionally validate the `g` shorthand separately on Windows.

## Files Created/Modified

- `.chezmoitemplates/aliases_ps1` — appended `## GitKraken` section with `gk` function and `g` alias

## Forward Intelligence

### What the next slice should know
- This is the only slice in M003-f3vdyg; the milestone is complete after this slice.
- The `gk` function pattern (glob → sort → guard → resolve → Start-Process) is a reusable template for other Windows GUI app launchers in `aliases_ps1`.

### What's fragile
- `Sort-Object Name -Descending` relies on GitKraken version directories being lexicographically sortable (e.g. `app-3.10.0`, `app-3.9.0`). This works correctly for semantic version strings padded to consistent width but could pick an unexpected entry if GitKraken ever changes its install dir naming convention.

### Authoritative diagnostics
- `grep -A 12 '## GitKraken' .chezmoitemplates/aliases_ps1` — fastest way to confirm the section is present and syntactically shaped correctly.
- `chezmoi execute-template < Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl 2>&1 | grep -A 10 'function gk'` — confirms the function renders into the actual deployed profile.

### What assumptions changed
- None — research had resolved all PS-specific questions before implementation began.
