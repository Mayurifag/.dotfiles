# S01: Add gk function and g alias to aliases_ps1

**Goal:** Add `gk` and `g` PowerShell definitions to `aliases_ps1` so Windows users can launch GitKraken from any git repo.
**Demo:** `grep -A 12 '## GitKraken' .chezmoitemplates/aliases_ps1` shows the function and alias; `chezmoi execute-template` renders the PS profile with both definitions.

## Must-Haves

- `gk` function that globs `$env:LOCALAPPDATA\gitkraken\app-*\gitkraken.exe`, picks newest by name, resolves git root via `Resolve-Path`, launches with `Start-Process`
- Guard clauses: "GitKraken not found" and "not a git repo" — both `Write-Warning` + early return
- `Set-Alias -Name g -Value gk` shorthand
- Uses `-p` flag (not `--path`) to match the confirmed-working zsh alias

## Verification

- `grep -c 'function gk' .chezmoitemplates/aliases_ps1` returns `1`
- `grep -c "Set-Alias -Name g -Value gk" .chezmoitemplates/aliases_ps1` returns `1`
- `chezmoi execute-template < Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl 2>&1 | grep -q 'function gk' && echo PASS || echo FAIL`
- `chezmoi apply --dry-run --force 2>&1 | grep -i error | grep -v 'ejson\|decrypt' | wc -l` returns `0` (ignore expected ejson errors on Linux)

## Tasks

- [x] **T01: Add GitKraken section to aliases_ps1** `est:10m`
  - Why: The only code change in this milestone — adds `gk` function and `g` alias to the PS aliases fragment
  - Files: `.chezmoitemplates/aliases_ps1`
  - Do: Append a `## GitKraken` section after `## grep` at the bottom of `aliases_ps1`. The section contains: (1) a `gk` function that globs the exe path with `Get-Item ... -ErrorAction SilentlyContinue`, sorts by Name descending, selects first, guards for missing exe and non-git-repo, resolves path with `Resolve-Path`, and launches with `Start-Process -FilePath $gkExe -ArgumentList "--new-window", "-p", $root`; (2) `Set-Alias -Name g -Value gk`
  - Verify: `grep -A 12 '## GitKraken' .chezmoitemplates/aliases_ps1` shows the complete section
  - Done when: The `## GitKraken` section is present and syntactically correct PS

- [x] **T02: Verify template rendering and chezmoi apply** `est:5m`
  - Why: Confirms the template fragment renders correctly in the PS profile and chezmoi apply produces no errors
  - Files: (no changes — verification only)
  - Do: Run `chezmoi execute-template` on the PS profile template and confirm `gk` and `g` appear. Run `chezmoi apply --dry-run` and check for errors.
  - Verify: Both `function gk` and `Set-Alias -Name g -Value gk` appear in rendered output; no apply errors
  - Done when: Template renders correctly and dry-run is clean

## Files Likely Touched

- `.chezmoitemplates/aliases_ps1`
