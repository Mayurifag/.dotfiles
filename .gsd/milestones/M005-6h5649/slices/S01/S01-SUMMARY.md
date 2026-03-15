---
id: S01
parent: M005-6h5649
milestone: M005-6h5649
provides:
  - gp function with upstream-conditional push logic in aliases_ps1
  - free function in System utilities section of aliases_ps1
  - czapply function with automatic profile re-source in PS profile
requires: []
affects: []
key_files:
  - .chezmoitemplates/aliases_ps1
  - Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl
key_decisions:
  - Capture $branch before string interpolation to match POSIX pattern; drop @args for parity
  - Used [int](...) cast with division-by-1024 inline rather than [Math]::Round for brevity
  - Used semicolon to sequence chezmoi apply -v and . $PROFILE on one line (matches POSIX spirit, keeps function body compact)
  - grep 'function gp' counts 2 due to substring match on 'function gpf' — not a defect
patterns_established:
  - Multi-line PowerShell function mirroring POSIX conditional alias using git config branch.<name>.merge
  - CimInstance-based system info query pattern follows existing myip DNS-query pattern (query → compute → format output)
  - Single-line compound function body with semicolon sequencing for short two-step operations
observability_surfaces:
  - chezmoi execute-template < .chezmoitemplates/aliases_ps1 | grep -A8 'function gp'
  - chezmoi execute-template < .chezmoitemplates/aliases_ps1 | grep -A8 'function free'
  - grep -A2 'czapply' Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl
drill_down_paths:
  - .gsd/milestones/M005-6h5649/slices/S01/tasks/T01-SUMMARY.md
  - .gsd/milestones/M005-6h5649/slices/S01/tasks/T02-SUMMARY.md
  - .gsd/milestones/M005-6h5649/slices/S01/tasks/T03-SUMMARY.md
  - .gsd/milestones/M005-6h5649/slices/S01/tasks/T04-SUMMARY.md
duration: ~25m
verification_result: passed
completed_at: 2026-03-15
---

# S01: Implement gp conditional, free function, and czapply re-source

**Three PowerShell parity gaps closed: `gp` now conditionally sets upstream, `free` reports memory in MB, and `czapply` auto-re-sources `$PROFILE` — all verified via `chezmoi execute-template` and `chezmoi apply --dry-run`.**

## What Happened

Four tasks executed sequentially against two template files.

**T01 — gp conditional:** The stub at lines 40–41 of `.chezmoitemplates/aliases_ps1` was replaced with a multi-line function that captures `$branch = git symbolic-ref --short HEAD`, checks `git config "branch.$branch.merge"` for an existing upstream, and conditionally runs `git push` (upstream exists) or `git push -u origin $branch` (no upstream). `@args` dropped for parity with the POSIX alias. Stub comment fully removed.

**T02 — free function:** Inserted after the `myip` closing brace in `## System utilities`. Queries `Get-CimInstance Win32_OperatingSystem` for `TotalVisibleMemorySize` and `FreePhysicalMemory` (KB), divides both by 1024 with `[int]` cast for MB, computes `$used = $total - $free`, and outputs a two-line header+data display aligned to match `free -m` style.

**T03 — czapply re-source:** Changed `function czapply { chezmoi apply -v }` to `function czapply { chezmoi apply -v; . $PROFILE }` and updated the preceding comment from "reload manually" to reflect automatic re-source behaviour.

**T04 — validation:** All 8 verification checks passed. The `grep -c 'function gp'` count of 2 is expected (substring match on `function gpf`) — not a defect; `grep -n` confirms the `gp` definition exists exactly once at line 40.

## Verification

| Check | Command | Expected | Actual | Result |
|-------|---------|----------|--------|--------|
| No stub comment | `grep -c 'stub' .chezmoitemplates/aliases_ps1` | 0 | 0 | ✓ |
| gp conditional | `grep 'git config "branch\.\$branch\.merge"'` | match | match | ✓ |
| free CimInstance | `grep 'Get-CimInstance Win32_OperatingSystem'` | match | match | ✓ |
| czapply re-source | `grep '\. \$PROFILE' ...profile.ps1.tmpl` | match | match | ✓ |
| aliases_ps1 renders | `chezmoi execute-template < .chezmoitemplates/aliases_ps1` | no error | no error | ✓ |
| profile renders | `chezmoi execute-template < ...profile.ps1.tmpl` | no error | no error | ✓ |
| dry-run zero errors | `chezmoi apply --dry-run --force 2>&1 \| grep -i error \| grep -v 'ejson\|decrypt' \| wc -l` | 0 | 0 | ✓ |

## Deviations

none

## Known Limitations

- Live Windows execution not tested — `Get-CimInstance` and `git symbolic-ref` behaviour verified structurally only
- `free` output is truncated to integer MB (no decimal precision); matches `free -m` spirit but not byte-exact

## Follow-ups

none

## Files Created/Modified

- `.chezmoitemplates/aliases_ps1` — `gp` stub replaced with conditional; `free` function added to `## System utilities`
- `Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl` — `czapply` expanded with `. $PROFILE`; stale comment updated

## Forward Intelligence

### What the next slice should know
- M005-6h5649 is complete — no further slices
- `grep 'function gp'` returns 2 lines (also matches `gpf`) — use `grep 'function gp '` or `grep -n '^function gp '` for exact match

### What's fragile
- `[int](... / 1024)` truncates rather than rounds — if precision matters in a future revision, use `[Math]::Round`
- Semicolon-sequenced `czapply` body: if `chezmoi apply -v` exits non-zero, `. $PROFILE` still runs (no short-circuit); acceptable for current use

### Authoritative diagnostics
- `chezmoi execute-template < .chezmoitemplates/aliases_ps1 | grep -A8 'function gp'` — confirms rendered conditional block
- `chezmoi execute-template < .chezmoitemplates/aliases_ps1 | grep -A8 'function free'` — confirms rendered CimInstance block
- `grep -A2 'czapply' Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl` — confirms re-source line

### What assumptions changed
- No assumptions changed — all three changes were straightforward as planned
