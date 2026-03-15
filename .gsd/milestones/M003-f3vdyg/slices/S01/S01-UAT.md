# S01: Add gk function and g alias to aliases_ps1 — UAT

**Milestone:** M003-f3vdyg
**Written:** 2026-03-15

## UAT Type

- UAT mode: artifact-driven (template rendering) + human-experience (Windows live test)
- Why this mode is sufficient: The Linux-side artifact checks (grep, chezmoi execute-template, dry-run) fully validate the template is correct. The remaining gap — whether GitKraken actually launches on a real Windows machine — is a human-experience test that can only be done manually on Windows after `chezmoi apply`.

## Preconditions

**For artifact-driven checks (Linux/CI):**
- Working directory: `/home/mayurifag/.local/share/chezmoi`
- `chezmoi` is installed and configured

**For Windows live test:**
- Windows machine with chezmoi applied (`chezmoi apply` has been run)
- GitKraken installed under `%LOCALAPPDATA%\gitkraken\app-*\`
- PowerShell session that has sourced the profile (open a new PowerShell window after `chezmoi apply`)
- At least one local git repository available

## Smoke Test

Run on Linux:
```sh
grep -c 'function gk' .chezmoitemplates/aliases_ps1
# Expected: 1
```

## Test Cases

### 1. Template file contains gk function and g alias

```sh
grep -A 12 '## GitKraken' .chezmoitemplates/aliases_ps1
```

**Expected:** Output shows the complete section:
```
## GitKraken
function gk {
    $gkExe = Get-Item "$env:LOCALAPPDATA\gitkraken\app-*\gitkraken.exe" -ErrorAction SilentlyContinue | Sort-Object Name -Descending | Select-Object -First 1 -ExpandProperty FullName
    if (-not $gkExe) { Write-Warning "GitKraken not found"; return }
    $root = git rev-parse --show-toplevel 2>$null
    if (-not $root) { Write-Warning "Not a git repository"; return }
    $root = (Resolve-Path $root).Path
    Start-Process -FilePath $gkExe -ArgumentList "--new-window", "-p", $root
}
Set-Alias -Name g -Value gk
```

### 2. chezmoi execute-template renders both definitions

```sh
chezmoi execute-template < Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl 2>&1 | grep -E 'function gk|Set-Alias -Name g -Value gk'
```

**Expected:** Two lines appear:
```
function gk {
Set-Alias -Name g -Value gk
```

### 3. chezmoi apply --dry-run introduces no new errors

```sh
chezmoi apply --dry-run --force 2>&1 | grep -i error | grep -v 'ejson\|decrypt'
```

**Expected:** Empty output (zero lines). Any remaining output should only be ejson/decrypt-related warnings which are expected on Linux.

### 4. [Windows] gk launches GitKraken at git repo root

1. Open a new PowerShell window (to pick up the freshly applied profile).
2. `cd` into any local git repository, e.g. `cd C:\Users\<user>\projects\chezmoi`.
3. Run `gk`.
4. **Expected:** GitKraken opens with the repository already loaded; PowerShell prompt returns immediately (non-blocking).

### 5. [Windows] g shorthand works identically to gk

1. From the same git repository directory as Test 4.
2. Run `g`.
3. **Expected:** Same behaviour as `gk` — GitKraken opens the repo in a new window; prompt returns immediately.

## Edge Cases

### [Windows] Not inside a git repository

1. `cd C:\Users\<user>\Desktop` (a non-git directory).
2. Run `gk`.
3. **Expected:** PowerShell prints `WARNING: Not a git repository`; no GitKraken window opens; prompt returns immediately.

### [Windows] GitKraken not installed

1. Temporarily rename or remove the GitKraken install directory, OR test on a machine without GitKraken.
2. Run `gk` from any git repo.
3. **Expected:** PowerShell prints `WARNING: GitKraken not found`; no crash or unhandled error; prompt returns immediately.

### [Windows] Multiple GitKraken versions installed

1. Confirm multiple `app-*` directories exist under `%LOCALAPPDATA%\gitkraken\`.
2. Run `gk`.
3. **Expected:** GitKraken launches (using the lexicographically newest `app-*` directory); no errors.

## Failure Signals

- `grep -c 'function gk' .chezmoitemplates/aliases_ps1` returns `0` — function was not appended.
- `chezmoi execute-template` output does not contain `function gk` — template fragment is not being included in the PS profile.
- `chezmoi apply --dry-run` output contains non-ejson error lines — template syntax error introduced.
- On Windows: `gk` throws a PowerShell exception instead of a `Write-Warning` message — guard clause is missing or broken.
- On Windows: GitKraken opens but blocks the prompt — `Start-Process` was accidentally given `-Wait`.

## Requirements Proved By This UAT

- none (this milestone introduces new scope beyond M001/M002 requirements)

## Not Proven By This UAT

- Actual GitKraken launch on Windows — requires the human-experience test (Tests 4 and 5 above) on a real Windows machine after `chezmoi apply`.
- Behaviour with GitKraken versions that use non-standard directory naming (e.g. `app-3.10.0` vs `app-3.9.0` sort order edge cases).

## Notes for Tester

- Tests 1–3 are fully automated and should be run on Linux/CI to confirm the artifact is correct before Windows testing.
- Tests 4, 5, and all edge cases require a Windows machine with GitKraken installed.
- The `g` alias is a `Set-Alias` pointing to `gk` — it will not appear as a distinct function in `Get-Command g` output; this is expected.
- ejson-related warnings from `chezmoi apply --dry-run` on Linux are expected and should be ignored (they relate to secret decryption unavailable on Linux).
