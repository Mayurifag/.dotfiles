# S01: Implement gp conditional, free function, and czapply re-source — UAT

**Milestone:** M005-6h5649
**Written:** 2026-03-15

## UAT Type

- UAT mode: artifact-driven
- Why this mode is sufficient: All three changes are static code edits to chezmoi template files. Correctness is fully verifiable by grep (source check), `chezmoi execute-template` (render check), and `chezmoi apply --dry-run` (integration check). Live Windows execution is not required to confirm the logic is present and syntactically valid.

## Preconditions

- Repo is at `~/.local/share/chezmoi`
- `chezmoi` is installed and on PATH
- Working directory is the repo root when running commands

## Smoke Test

```bash
grep '\. \$PROFILE' Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl && \
grep 'Get-CimInstance Win32_OperatingSystem' .chezmoitemplates/aliases_ps1 && \
grep 'git config "branch\.\$branch\.merge"' .chezmoitemplates/aliases_ps1 && \
echo "SMOKE PASS"
```
Expected: all three grep lines match and `SMOKE PASS` is printed.

## Test Cases

### 1. gp stub is gone and conditional logic is present

1. Run: `grep -c 'stub' .chezmoitemplates/aliases_ps1`
2. **Expected:** `0` — no stub comment remains

3. Run: `grep 'git config "branch\.\$branch\.merge"' .chezmoitemplates/aliases_ps1`
4. **Expected:** matches line `    if (git config "branch.$branch.merge") {`

5. Run: `grep 'git push -u origin \$branch' .chezmoitemplates/aliases_ps1`
6. **Expected:** matches line `        git push -u origin $branch`

7. Run: `grep -n '^function gp ' .chezmoitemplates/aliases_ps1` (or `grep -n 'function gp {'`)
8. **Expected:** exactly one match at the `gp` definition line (not `gpf`)

### 2. gp function renders correctly in output template

1. Run: `chezmoi execute-template < .chezmoitemplates/aliases_ps1 | grep -A8 'function gp {'`
2. **Expected:** rendered output contains all of:
   - `$branch = git symbolic-ref --short HEAD`
   - `if (git config "branch.$branch.merge") {`
   - `git push`
   - `git push -u origin $branch`
   - closing `}`

### 3. free function is present in System utilities section

1. Run: `grep 'Get-CimInstance Win32_OperatingSystem' .chezmoitemplates/aliases_ps1`
2. **Expected:** matches `$os    = Get-CimInstance Win32_OperatingSystem`

3. Run: `grep 'TotalVisibleMemorySize' .chezmoitemplates/aliases_ps1`
4. **Expected:** matches the KB→MB division line

5. Run: `grep 'FreePhysicalMemory' .chezmoitemplates/aliases_ps1`
6. **Expected:** matches the free-memory assignment line

### 4. free function renders with correct output format

1. Run: `chezmoi execute-template < .chezmoitemplates/aliases_ps1 | grep -A8 'function free {'`
2. **Expected:** rendered output contains all of:
   - `Get-CimInstance Win32_OperatingSystem`
   - `/` division expressions (KB→MB)
   - `$used  = $total - $free`
   - header line: `total        used        free`
   - `Write-Output` data format line with `{0,11}` alignment

### 5. czapply auto-sources profile after apply

1. Run: `grep '\. \$PROFILE' Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl`
2. **Expected:** matches `function czapply { chezmoi apply -v; . $PROFILE }`

3. Run: `grep -c 'reload manually' Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl`
4. **Expected:** `0` — stale comment fully replaced

### 6. Both templates render without errors

1. Run: `chezmoi execute-template < .chezmoitemplates/aliases_ps1 > /dev/null && echo "aliases_ps1 OK"`
2. **Expected:** `aliases_ps1 OK` — no template parse error

3. Run: `chezmoi execute-template < Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl > /dev/null && echo "profile OK"`
4. **Expected:** `profile OK` — no template parse error

### 7. chezmoi apply dry-run produces zero errors

1. Run: `chezmoi apply --dry-run --force 2>&1 | grep -i error | grep -v 'ejson\|decrypt'`
2. **Expected:** empty output (zero lines)

3. Confirm: `chezmoi apply --dry-run --force 2>&1 | grep -i error | grep -v 'ejson\|decrypt' | wc -l`
4. **Expected:** `0`

## Edge Cases

### gpf does not break gp grep count

1. Run: `grep -c 'function gp' .chezmoitemplates/aliases_ps1`
2. **Expected:** `2` — this is normal; `gpf` contains the substring `gp`. Use `grep '^function gp '` to isolate the exact `gp` definition.
3. Run: `grep '^function gp ' .chezmoitemplates/aliases_ps1 | wc -l`
4. **Expected:** `1`

### free does not shadow a built-in

1. Run: `grep -n 'function free' .chezmoitemplates/aliases_ps1`
2. **Expected:** exactly one match — the new function in `## System utilities`; no duplicate definition elsewhere in the file

### czapply semicolon sequencing — no short-circuit on error

1. Inspect: `grep 'czapply' Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl`
2. **Expected:** single-line `chezmoi apply -v; . $PROFILE` — note `;` not `&&`; `. $PROFILE` runs regardless of apply exit code. This is intentional (matches POSIX spirit) but testers should be aware it will re-source even if apply failed.

## Failure Signals

- `grep -c 'stub' .chezmoitemplates/aliases_ps1` returns non-zero → stub comment not removed (T01 regression)
- `chezmoi execute-template < .chezmoitemplates/aliases_ps1` exits non-zero or emits `ERROR` → template syntax broken
- `chezmoi apply --dry-run --force` emits error lines (excluding ejson/decrypt) → template or file structure issue
- `grep '\. \$PROFILE'` returns no match → T03 change not present
- `grep 'Get-CimInstance'` returns no match → T02 change not present

## Requirements Proved By This UAT

- none (parity/maintenance work — no active requirement IDs tracked)

## Not Proven By This UAT

- Live Windows runtime execution of `gp`, `free`, or `czapply` — verified structurally only
- That `git config "branch.$branch.merge"` correctly returns truthy/falsy in all PowerShell environments
- That `Get-CimInstance Win32_OperatingSystem` is available on the target Windows version (assumed standard)
- That `. $PROFILE` correctly reloads all profile content after `chezmoi apply -v` completes

## Notes for Tester

- All checks can be run on Linux from the chezmoi repo root — no Windows required for artifact-driven verification
- The `grep -c 'function gp'` count of 2 is expected and correct — do not flag as a failure
- `chezmoi apply --dry-run` may emit ejson/decrypt warnings if ejson is not configured locally — filter these with `grep -v 'ejson\|decrypt'` as shown above; these are not errors in this slice's scope
