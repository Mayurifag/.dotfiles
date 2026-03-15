---
estimated_steps: 3
estimated_files: 0
---

# T04: Validate templates render and apply cleanly

**Slice:** S01 — Implement gp conditional, free function, and czapply re-source
**Milestone:** M005-6h5649

## Description

Run `chezmoi execute-template` on `aliases_ps1` and the PS profile template to confirm all three changes render correctly. Run `chezmoi apply --dry-run --force` to confirm no template parse or apply errors.

## Steps

1. Run `chezmoi execute-template < .chezmoitemplates/aliases_ps1` and verify output contains `function gp` with conditional, `function free` with CimInstance, and no stub comment
2. Run `chezmoi execute-template < Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl` and verify output contains `czapply` with `. $PROFILE`
3. Run `chezmoi apply --dry-run --force 2>&1 | grep -i error | grep -v 'ejson\|decrypt'` and confirm zero lines

## Must-Haves

- [ ] `chezmoi execute-template` renders both files without error
- [ ] `chezmoi apply --dry-run` produces zero errors (excluding ejson/decrypt noise)

## Verification

- `chezmoi execute-template < .chezmoitemplates/aliases_ps1 | grep -c 'function gp'` → 1
- `chezmoi execute-template < .chezmoitemplates/aliases_ps1 | grep -c 'function free'` → 1
- `chezmoi execute-template < Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl | grep -c '\. \$PROFILE'` → 1
- `chezmoi apply --dry-run --force 2>&1 | grep -i error | grep -v 'ejson\|decrypt' | wc -l` → 0

## Inputs

- `.chezmoitemplates/aliases_ps1` — modified by T01 and T02
- `Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl` — modified by T03

## Expected Output

- No file changes — validation only; all checks pass
