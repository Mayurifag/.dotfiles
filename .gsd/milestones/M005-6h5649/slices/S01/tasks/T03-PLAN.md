---
estimated_steps: 2
estimated_files: 1
---

# T03: Add profile re-source to czapply and update comment

**Slice:** S01 — Implement gp conditional, free function, and czapply re-source
**Milestone:** M005-6h5649

## Description

Update the `czapply` function in `Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl` to add `. $PROFILE` after `chezmoi apply -v`, matching the POSIX behaviour where the shell config is re-sourced after apply. Also update the stale comment that says "reload manually if needed".

## Steps

1. Locate the comment and function (lines 23–24):
   - `# chezmoi apply — PS profile doesn't self-source; reload manually if needed`
   - `function czapply { chezmoi apply -v }`
2. Update the comment to reflect that czapply now re-sources automatically
3. Expand the function body to include `. $PROFILE` after `chezmoi apply -v`

## Must-Haves

- [ ] `czapply` function body contains both `chezmoi apply -v` and `. $PROFILE`
- [ ] Comment updated — no longer says "reload manually"

## Verification

- `grep '\. \$PROFILE' Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl` matches
- `grep -c 'reload manually' Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl` returns 0

## Inputs

- `Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl` lines 23–24 — current czapply

## Expected Output

- `Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl` — `czapply` updated with re-source and accurate comment
