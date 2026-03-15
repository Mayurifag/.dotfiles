---
id: T03
parent: S01
milestone: M005-6h5649
provides:
  - czapply function with automatic profile re-source after chezmoi apply
key_files:
  - Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl
key_decisions:
  - Used semicolon to sequence chezmoi apply -v and . $PROFILE on one line (matches POSIX spirit, keeps function body compact)
patterns_established:
  - Single-line compound function body with semicolon sequencing for short two-step operations
observability_surfaces:
  - none
duration: ~5m
verification_result: passed
completed_at: 2026-03-15
blocker_discovered: false
---

# T03: Add profile re-source to czapply and update comment

**Updated `czapply` to run `. $PROFILE` after `chezmoi apply -v` and corrected the stale "reload manually" comment.**

## What Happened

Located lines 23–24 in `Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl`. Replaced the old comment and single-statement function with a two-statement body (`chezmoi apply -v; . $PROFILE`) and an accurate comment reflecting the automatic re-source behaviour.

## Verification

- `grep '\. \$PROFILE' Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl` — matches, PASS
- `grep -c 'reload manually' Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl` — returns 0, PASS
- All 6 slice-level checks pass:
  1. `grep -c 'stub' .chezmoitemplates/aliases_ps1` → 0 (PASS)
  2. `gp` conditional present (PASS)
  3. `free` function present (PASS)
  4. `czapply` re-source present (PASS)
  5. `chezmoi execute-template < .chezmoitemplates/aliases_ps1` renders without error (PASS)
  6. `chezmoi apply --dry-run --force` 0 error lines (PASS)

## Diagnostics

Inspect the updated function at any time:
```
grep -A2 'czapply' Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl
```

## Deviations

none

## Known Issues

none

## Files Created/Modified

- `Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl` — `czapply` expanded with `. $PROFILE` re-source; stale comment updated
