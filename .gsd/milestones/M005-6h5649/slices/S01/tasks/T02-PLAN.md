---
estimated_steps: 3
estimated_files: 1
---

# T02: Add free function to System utilities section

**Slice:** S01 — Implement gp conditional, free function, and czapply re-source
**Milestone:** M005-6h5649

## Description

Add a `free` function to the `## System utilities` section of `.chezmoitemplates/aliases_ps1`, after the existing `myip` function. The function uses `Get-CimInstance Win32_OperatingSystem` to retrieve `TotalVisibleMemorySize` and `FreePhysicalMemory` (both in KB), computes used memory, divides by 1024 for MB, and displays a concise formatted summary matching the spirit of `free -m`.

## Steps

1. Locate the `myip` function end in `## System utilities` section (after the closing `}`)
2. Insert a `free` function that:
   - Queries `Get-CimInstance Win32_OperatingSystem` for `TotalVisibleMemorySize` and `FreePhysicalMemory` (both KB)
   - Computes `$used = $total - $free`
   - Divides all three by 1024 and rounds to integer for MB display
   - Outputs a header line and a data line with aligned columns (Total / Used / Free in MB)
3. Ensure the function sits between `myip` closing brace and the `## GitKraken` section

## Must-Haves

- [ ] Uses `Get-CimInstance Win32_OperatingSystem` (not `Win32_PhysicalMemory` for the summary — OS class has both total visible and free)
- [ ] Values displayed in MB (KB ÷ 1024)
- [ ] Output has labeled columns (total, used, free) for readability

## Verification

- `grep 'function free' .chezmoitemplates/aliases_ps1` matches
- `grep 'Get-CimInstance Win32_OperatingSystem' .chezmoitemplates/aliases_ps1` matches
- `grep 'TotalVisibleMemorySize' .chezmoitemplates/aliases_ps1` matches

## Inputs

- `.chezmoitemplates/aliases_ps1` — `## System utilities` section with `df`, `du`, `myip` pattern

## Expected Output

- `.chezmoitemplates/aliases_ps1` — `free` function added after `myip` in `## System utilities`
