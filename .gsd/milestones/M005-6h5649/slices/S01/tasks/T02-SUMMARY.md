---
id: T02
parent: S01
milestone: M005-6h5649
provides:
  - free function in System utilities section of aliases_ps1
key_files:
  - .chezmoitemplates/aliases_ps1
key_decisions:
  - Used [int](...) cast with division-by-1024 inline rather than [Math]::Round for brevity; output matches free -m spirit with aligned columns
patterns_established:
  - CimInstance-based system info query pattern follows existing myip DNS-query pattern (query → compute → format output)
observability_surfaces:
  - Diagnostic command: chezmoi execute-template < .chezmoitemplates/aliases_ps1 | grep -A8 'function free'
duration: ~5m
verification_result: passed
completed_at: 2026-03-15
blocker_discovered: false
---

# T02: Add free function to System utilities section

**Added `free` PowerShell function using `Get-CimInstance Win32_OperatingSystem` that displays total/used/free memory in MB with aligned columns, matching the spirit of `free -m`.**

## What Happened

Located the `myip` function closing brace in `## System utilities` (line 115) and inserted a `free` function directly after it, before the `## GitKraken` section. The function:
- Queries `Get-CimInstance Win32_OperatingSystem` for `TotalVisibleMemorySize` and `FreePhysicalMemory` (both KB)
- Divides each value by 1024 with `[int]` cast for MB display
- Computes `$used = $total - $free`
- Outputs a two-line display: header row with column labels, data row with right-aligned values

## Verification

All three must-have greps pass:
```
grep 'function free' .chezmoitemplates/aliases_ps1          → match
grep 'Get-CimInstance Win32_OperatingSystem' ...            → match
grep 'TotalVisibleMemorySize' ...                           → match
```
Template renders cleanly:
```
chezmoi execute-template < .chezmoitemplates/aliases_ps1 | grep -A8 'function free'
→ full 8-line function body rendered without error
```
Dry-run passes with zero error lines:
```
chezmoi apply --dry-run --force 2>&1 | grep -i error | grep -v 'ejson\|decrypt'
→ (empty — exit 1 from grep means no matches, which is correct)
```

Applicable slice checks:
- `grep -c 'stub' .chezmoitemplates/aliases_ps1` → 0 ✓
- `grep 'git config "branch\.\$branch\.merge"'` → match ✓ (from T01)
- `grep 'Get-CimInstance Win32_OperatingSystem'` rendered count → 1 ✓

## Diagnostics

Inspect rendered function at any time:
```
chezmoi execute-template < .chezmoitemplates/aliases_ps1 | grep -A8 'function free'
```

## Deviations

none

## Known Issues

none

## Files Created/Modified

- `.chezmoitemplates/aliases_ps1` — `free` function added after `myip` in `## System utilities` section
- `.gsd/milestones/M005-6h5649/slices/S01/tasks/T02-SUMMARY.md` — this summary
