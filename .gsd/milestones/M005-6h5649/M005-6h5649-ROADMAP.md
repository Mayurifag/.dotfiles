# M005-6h5649: PowerShell Alias Parity

**Vision:** Close three parity gaps between `aliases_posix` and `aliases_ps1` — `gp` conditional push, `free` memory summary, and `czapply` auto re-source — so PowerShell behaviour matches zsh.

## Success Criteria

- `gp` in `aliases_ps1` uses a branch-name variable and conditional: runs `git push` when upstream exists, `git push -u origin <branch>` when it doesn't — no stub comment remains
- `free` function exists in `aliases_ps1` under `## System utilities`, uses `Get-CimInstance Win32_OperatingSystem` to display total/used/free memory in MB
- `czapply` in `Microsoft.PowerShell_profile.ps1.tmpl` runs `. $PROFILE` after `chezmoi apply -v`; the stale "reload manually" comment is updated
- `chezmoi execute-template` renders both files with all three changes present
- `chezmoi apply --dry-run` produces zero errors

## Key Risks / Unknowns

None — all three changes are small, isolated PS edits with well-understood syntax. No new dependencies, no runtime boundaries.

## Verification Classes

- Contract verification: `grep` on source files confirms correct code; `chezmoi execute-template` renders correctly
- Integration verification: `chezmoi apply --dry-run` produces zero errors
- Operational verification: none (Windows live testing not required)
- UAT / human verification: none

## Milestone Definition of Done

This milestone is complete only when all are true:

- `gp` function in `aliases_ps1` contains the upstream-check conditional and no stub comment
- `free` function in `aliases_ps1` is present with `Get-CimInstance` call and MB output
- `czapply` in PS profile contains `. $PROFILE` after `chezmoi apply -v`
- `chezmoi execute-template` renders both files with all three changes
- `chezmoi apply --dry-run --force` produces zero errors (excluding ejson/decrypt noise)

## Requirement Coverage

- No active requirements — this is parity/maintenance work deferred from M001
- All three items were explicitly noted as deferred in M001 context (`gp` stub comment, `free` absence, `czapply` manual reload)

## Slices

- [x] **S01: Implement gp conditional, free function, and czapply re-source** `risk:low` `depends:[]`
  > After this: `aliases_ps1` contains the full `gp` conditional, a `free` function, and the PS profile's `czapply` re-sources automatically; `chezmoi execute-template` and `chezmoi apply --dry-run` both pass

## Boundary Map

### S01

Produces:
- Updated `gp` function in `.chezmoitemplates/aliases_ps1` with branch-variable conditional logic
- New `free` function in `.chezmoitemplates/aliases_ps1` under `## System utilities`
- Updated `czapply` function in `Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl` with `. $PROFILE`

Consumes:
- nothing (single slice, no prior dependencies)
