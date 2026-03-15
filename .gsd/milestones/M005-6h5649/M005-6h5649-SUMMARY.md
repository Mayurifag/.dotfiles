---
id: M005-6h5649
provides:
  - gp function with upstream-conditional push logic in aliases_ps1
  - free function in System utilities section of aliases_ps1
  - czapply function with automatic profile re-source in PS profile
key_decisions:
  - Capture $branch before string interpolation to match POSIX pattern; drop @args for parity (D016)
  - Used [int](...) cast with division-by-1024 inline rather than [Math]::Round for brevity (D018)
  - Used semicolon to sequence chezmoi apply -v and . $PROFILE on one line (D017)
patterns_established:
  - Multi-line PowerShell function mirroring POSIX conditional alias using git config branch.<name>.merge
  - CimInstance-based system info query pattern follows existing myip DNS-query pattern (query → compute → format output)
  - Single-line compound function body with semicolon sequencing for short two-step operations
observability_surfaces:
  - chezmoi execute-template < .chezmoitemplates/aliases_ps1 | grep -A5 'function gp '
  - chezmoi execute-template < .chezmoitemplates/aliases_ps1 | grep -A8 'function free'
  - grep 'czapply' Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl
requirement_outcomes: []
duration: ~25m
verification_result: passed
completed_at: 2026-03-15
---

# M005-6h5649: PowerShell Alias Parity

**Three PowerShell parity gaps closed: `gp` now conditionally sets upstream, `free` reports memory in MB, and `czapply` auto-re-sources `$PROFILE` — all verified via `chezmoi execute-template` and `chezmoi apply --dry-run`.**

## What Happened

Single-slice milestone (S01) against two template files. The S01 summary reported completion but the files retained the stub — the actual edits were applied during M005 completion.

**gp conditional:** The stub at lines 48–49 of `.chezmoitemplates/aliases_ps1` (`# gp: stub — pushes with -u to set upstream; full conditional logic not ported from zsh` + single-line function) was replaced with a multi-line function that captures `$branch = git symbolic-ref --short HEAD`, checks `git config "branch.$branch.merge"` for an existing upstream, and conditionally runs `git push` (upstream exists) or `git push -u origin $branch` (no upstream). `@args` dropped for parity with the POSIX alias.

**free function:** Inserted after the `myip` closing brace in `## System utilities`. Queries `Get-CimInstance Win32_OperatingSystem` for `TotalVisibleMemorySize` and `FreePhysicalMemory` (KB), divides both by 1024 with `[int]` cast for MB, computes `$used = $total - $free`, and outputs a two-line header+data display aligned to match `free -m` style.

**czapply re-source:** `Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl` already contained `function czapply { chezmoi apply -v; . $PROFILE }` and the updated comment — this gap was already closed.

## Cross-Slice Verification

| Check | Command | Expected | Actual | Result |
|-------|---------|----------|--------|--------|
| No stub comment | `grep -c 'stub' .chezmoitemplates/aliases_ps1` | 0 | 0 | ✓ |
| gp conditional | `grep 'branch\.\$branch\.merge' .chezmoitemplates/aliases_ps1` | match | match | ✓ |
| free CimInstance | `grep 'Get-CimInstance Win32_OperatingSystem' .chezmoitemplates/aliases_ps1` | match | match | ✓ |
| czapply re-source | `grep '\. \$PROFILE' Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl` | match | match | ✓ |
| aliases_ps1 renders gp | `chezmoi execute-template < .chezmoitemplates/aliases_ps1 \| grep -A5 'function gp '` | conditional block | conditional block | ✓ |
| aliases_ps1 renders free | `chezmoi execute-template < .chezmoitemplates/aliases_ps1 \| grep -A8 'function free'` | CimInstance block | CimInstance block | ✓ |
| profile renders czapply | `chezmoi execute-template < .../profile.ps1.tmpl \| grep 'czapply'` | `. $PROFILE` present | `. $PROFILE` present | ✓ |
| dry-run zero errors | `chezmoi apply --dry-run --force 2>&1 \| grep -i error \| grep -v 'ejson\|decrypt' \| wc -l` | 0 | 0 | ✓ |

All 8 success criteria from the milestone definition confirmed met.

## Requirement Changes

No active requirements were registered for this milestone — parity/maintenance work only. No requirement status transitions.

## Forward Intelligence

### What the next milestone should know
- M005-6h5649 is the final milestone in the M001–M005 sequence — the project is complete
- All requirements in PROJECT.md are now validated

### What's fragile
- `[int](... / 1024)` truncates rather than rounds — if precision matters in a future revision, use `[Math]::Round`
- Semicolon-sequenced `czapply` body: if `chezmoi apply -v` exits non-zero, `. $PROFILE` still runs (no short-circuit); acceptable for current use

### Authoritative diagnostics
- `chezmoi execute-template < .chezmoitemplates/aliases_ps1 | grep -A5 'function gp '` — confirms rendered conditional block
- `chezmoi execute-template < .chezmoitemplates/aliases_ps1 | grep -A8 'function free'` — confirms rendered CimInstance block
- `grep 'czapply' Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl` — confirms re-source line

### What assumptions changed
- S01 summary claimed completion but files were not updated — the actual edits were applied during M005 completion run

## Files Created/Modified

- `.chezmoitemplates/aliases_ps1` — `gp` stub replaced with upstream-conditional function; `free` function added to `## System utilities`
- `Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl` — `czapply` with `. $PROFILE` was already present (no edit required)
