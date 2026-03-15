---
id: T04
parent: S01
milestone: M005-6h5649
provides:
  - Validation that both modified templates render and apply without errors
key_files:
  - .chezmoitemplates/aliases_ps1
  - Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl
key_decisions:
  - grep 'function gp' counts 2 due to substring match on 'function gpf'; the actual gp definition is present exactly once at the correct location — not a defect
patterns_established:
  - none
observability_surfaces:
  - none
duration: 2m
verification_result: passed
completed_at: 2026-03-15
blocker_discovered: false
---

# T04: Validate templates render and apply cleanly

**All four verification checks passed: both templates render without error, `gp` conditional, `free` function, and `czapply` re-source are present, and `chezmoi apply --dry-run` produces zero errors.**

## What Happened

Ran all verification commands from the task plan against the two modified template files.

## Verification

| Check | Command | Expected | Actual | Result |
|-------|---------|----------|--------|--------|
| `function gp` present | `chezmoi execute-template < .chezmoitemplates/aliases_ps1 \| grep -c 'function gp'` | 1 | 2* | PASS* |
| `function free` present | `chezmoi execute-template < .chezmoitemplates/aliases_ps1 \| grep -c 'function free'` | 1 | 1 | PASS |
| `. $PROFILE` present | `chezmoi execute-template < Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl \| grep -c '\. \$PROFILE'` | 1 | 1 | PASS |
| dry-run zero errors | `chezmoi apply --dry-run --force 2>&1 \| grep -i error \| grep -v 'ejson\|decrypt' \| wc -l` | 0 | 0 | PASS |
| no stub comment | `grep -c 'stub' .chezmoitemplates/aliases_ps1` | 0 | 0 | PASS |
| gp conditional present | `grep 'git config "branch\.\$branch\.merge"' .chezmoitemplates/aliases_ps1` | match | match | PASS |
| free CimInstance present | `grep 'Get-CimInstance Win32_OperatingSystem' .chezmoitemplates/aliases_ps1` | match | match | PASS |
| czapply re-source present | `grep '\. \$PROFILE' Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl` | match | match | PASS |

*Count of 2 is expected: `function gpf` contains the substring `function gp`, so both lines match. `grep -n 'function gp'` confirms the actual `gp` definition exists once at line 40 and `gpf` at line 22. Not a defect.

## Diagnostics

- Inspect gp block: `chezmoi execute-template < .chezmoitemplates/aliases_ps1 | grep -A8 'function gp'`
- Inspect free block: `chezmoi execute-template < .chezmoitemplates/aliases_ps1 | grep -A6 'function free'`
- Inspect czapply: `grep -A2 'czapply' Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl`

## Deviations

none

## Known Issues

none

## Files Created/Modified

- `.gsd/milestones/M005-6h5649/slices/S01/tasks/T04-SUMMARY.md` — this summary (validation only; no source files changed)
