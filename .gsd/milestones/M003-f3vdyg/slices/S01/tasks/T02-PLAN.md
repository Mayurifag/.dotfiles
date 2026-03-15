---
estimated_steps: 3
estimated_files: 0
---

# T02: Verify template rendering and chezmoi apply

**Slice:** S01 — Add gk function and g alias to aliases_ps1
**Milestone:** M003-f3vdyg

## Description

Verify that the `aliases_ps1` template fragment renders correctly within the PowerShell profile template and that `chezmoi apply --dry-run` produces no errors from the change. This is the contract verification for the milestone since integration testing requires Windows + GitKraken.

## Steps

1. Run `chezmoi execute-template` on the PS profile template and confirm `function gk` appears in the output
2. Confirm `Set-Alias -Name g -Value gk` appears in the rendered output
3. Run `chezmoi apply --dry-run --force` and check that no errors are introduced by the change

## Must-Haves

- [ ] `function gk` present in rendered PS profile output
- [ ] `Set-Alias -Name g -Value gk` present in rendered PS profile output
- [ ] `chezmoi apply --dry-run` introduces no new errors

## Verification

- `chezmoi execute-template < Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl 2>&1 | grep -q 'function gk' && echo PASS || echo FAIL` → PASS
- `chezmoi execute-template < Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl 2>&1 | grep -q 'Set-Alias -Name g -Value gk' && echo PASS || echo FAIL` → PASS

## Inputs

- `.chezmoitemplates/aliases_ps1` — modified in T01
- `Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl` — PS profile template that consumes `aliases_ps1`

## Expected Output

- No file changes — verification only
- Confirmation that template rendering and dry-run are clean
