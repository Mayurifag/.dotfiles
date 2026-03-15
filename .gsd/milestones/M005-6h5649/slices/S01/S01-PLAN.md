# S01: Implement gp conditional, free function, and czapply re-source

**Goal:** All three PowerShell parity gaps are closed in two files.
**Demo:** `grep` confirms `gp` conditional, `free` function, and `czapply` re-source are present; `chezmoi execute-template` renders both files correctly; `chezmoi apply --dry-run` passes.

## Must-Haves

- `gp` captures branch name as `$branch`, checks `git config "branch.$branch.merge"`, conditionally runs `git push` or `git push -u origin $branch`
- `free` uses `Get-CimInstance Win32_OperatingSystem` for `TotalVisibleMemorySize`/`FreePhysicalMemory` (in KB), divides by 1024 for MB output
- `czapply` body is `chezmoi apply -v` followed by `. $PROFILE`; comment updated to reflect auto-reload

## Verification

- `grep -c 'stub' .chezmoitemplates/aliases_ps1` returns 0 (stub comment removed)
- `grep 'git config "branch\.\$branch\.merge"' .chezmoitemplates/aliases_ps1` matches (conditional present)
- `grep 'Get-CimInstance Win32_OperatingSystem' .chezmoitemplates/aliases_ps1` matches (free function present)
- `grep '\. \$PROFILE' Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl` matches (re-source present)
- `chezmoi execute-template < .chezmoitemplates/aliases_ps1` renders without error and contains all three
- `chezmoi apply --dry-run --force 2>&1 | grep -i error | grep -v 'ejson\|decrypt'` returns 0 lines

## Observability / Diagnostics

- **Inspect rendered output:** `chezmoi execute-template < .chezmoitemplates/aliases_ps1 | grep -A8 'function gp'` — confirms the conditional block is present in the rendered file
- **Inspect rendered output (free):** `chezmoi execute-template < .chezmoitemplates/aliases_ps1 | grep -A6 'function free'`
- **Dry-run failures:** `chezmoi apply --dry-run --force 2>&1` — any template parse error surfaces here; filter real errors with `grep -i error | grep -v 'ejson\|decrypt'`
- **No secrets involved** — no redaction constraints apply to these template files

## Tasks

- [x] **T01: Replace gp stub with full conditional** `est:10m`
  - Why: The `gp` stub always pushes with `-u`; the POSIX version conditionally omits `-u` when upstream exists
  - Files: `.chezmoitemplates/aliases_ps1`
  - Do: Replace the stub comment + function (lines 40–41) with a multi-line function that captures `$branch = git symbolic-ref --short HEAD`, checks `git config "branch.$branch.merge"`, and conditionally runs `git push` or `git push -u origin $branch`; drop `@args` for parity with POSIX version
  - Verify: `grep -c 'stub' .chezmoitemplates/aliases_ps1` → 0; `grep 'git config' .chezmoitemplates/aliases_ps1` matches
  - Done when: `gp` function has conditional logic, no stub comment remains

- [x] **T02: Add free function to System utilities section** `est:10m`
  - Why: POSIX has `alias free='free -m'`; Windows has no equivalent; PS function fills the gap
  - Files: `.chezmoitemplates/aliases_ps1`
  - Do: Insert a `free` function after `myip` in the `## System utilities` section; use `Get-CimInstance Win32_OperatingSystem` to get `TotalVisibleMemorySize` and `FreePhysicalMemory` (both in KB); compute used = total − free; divide all by 1024 for MB; format output with aligned columns matching `free -m` style
  - Verify: `grep 'Get-CimInstance Win32_OperatingSystem' .chezmoitemplates/aliases_ps1` matches
  - Done when: `free` function is present in `## System utilities` section with CimInstance call and MB output

- [x] **T03: Add profile re-source to czapply and update comment** `est:5m`
  - Why: POSIX `czapply` re-sources after apply; PS version requires manual `. $PROFILE`
  - Files: `Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl`
  - Do: Change `function czapply { chezmoi apply -v }` to include `. $PROFILE` as second statement; update the comment on the preceding line from "reload manually if needed" to reflect auto-reload
  - Verify: `grep '\. \$PROFILE' Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl` matches
  - Done when: `czapply` body contains both `chezmoi apply -v` and `. $PROFILE`; comment is accurate

- [x] **T04: Validate templates render and apply cleanly** `est:5m`
  - Why: Final integration check — templates must render and chezmoi must not error
  - Files: none (validation only)
  - Do: Run `chezmoi execute-template` on `aliases_ps1` and confirm all three functions appear; run `chezmoi apply --dry-run --force` and confirm zero errors
  - Verify: `chezmoi execute-template < .chezmoitemplates/aliases_ps1 | grep -c 'function gp'` → 1; same for `free`; `chezmoi apply --dry-run --force 2>&1 | grep -i error | grep -v 'ejson\|decrypt' | wc -l` → 0
  - Done when: Both commands pass with expected output

## Files Likely Touched

- `.chezmoitemplates/aliases_ps1`
- `Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl`
