---
id: T01
parent: S01
milestone: M005-6h5649
provides:
  - gp function with upstream-conditional push logic in aliases_ps1
key_files:
  - .chezmoitemplates/aliases_ps1
key_decisions:
  - Capture $branch before string interpolation to match POSIX pattern; drop @args for parity
patterns_established:
  - Multi-line PowerShell function mirroring POSIX conditional alias using git config branch.<name>.merge
observability_surfaces:
  - chezmoi execute-template < .chezmoitemplates/aliases_ps1 | grep -A8 'function gp'
duration: 5m
verification_result: passed
completed_at: 2026-03-15
blocker_discovered: false
---

# T01: Replace gp stub with full conditional

**Replaced the `gp` stub with a full conditional function that checks for an upstream tracking branch before deciding whether to run `git push` or `git push -u origin $branch`.**

## What Happened

Located the stub at lines 40–41 of `.chezmoitemplates/aliases_ps1`. Replaced it with a multi-line function that:
1. Captures `$branch = git symbolic-ref --short HEAD`
2. Checks `git config "branch.$branch.merge"` — truthy output means upstream exists
3. If upstream exists: `git push`
4. If no upstream: `git push -u origin $branch`

Stub comment removed; `@args` dropped for parity with the POSIX alias. Also added the missing `## Observability Impact` section to `T01-PLAN.md` and `## Observability / Diagnostics` section to `S01-PLAN.md` per pre-flight requirements.

## Verification

```
grep -c 'stub' .chezmoitemplates/aliases_ps1
# → 0  ✓

grep 'git config "branch\.\$branch\.merge"' .chezmoitemplates/aliases_ps1
# → matches  ✓

grep 'git push -u origin \$branch' .chezmoitemplates/aliases_ps1
# → matches  ✓

grep -P 'git push$' .chezmoitemplates/aliases_ps1
# → matches  ✓

chezmoi execute-template < .chezmoitemplates/aliases_ps1
# → renders without error  ✓
```

## Diagnostics

Inspect rendered `gp` function: `chezmoi execute-template < .chezmoitemplates/aliases_ps1 | grep -A8 'function gp'`

## Deviations

none

## Known Issues

none

## Files Created/Modified

- `.chezmoitemplates/aliases_ps1` — stub replaced with full conditional `gp` function
- `.gsd/milestones/M005-6h5649/slices/S01/S01-PLAN.md` — added `## Observability / Diagnostics` section; marked T01 `[x]`
- `.gsd/milestones/M005-6h5649/slices/S01/tasks/T01-PLAN.md` — added `## Observability Impact` section
