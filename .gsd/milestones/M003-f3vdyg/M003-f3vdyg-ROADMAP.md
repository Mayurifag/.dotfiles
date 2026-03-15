# M003-f3vdyg: GitKraken PS Alias

**Vision:** `gk` and `g` commands work in PowerShell on Windows, launching GitKraken at the current git project root — matching the zsh muscle memory already established on Linux/macOS.

## Success Criteria

- `.chezmoitemplates/aliases_ps1` contains a `gk` function that globs the newest GitKraken versioned install dir, resolves the git root, and launches GitKraken via `Start-Process` (non-blocking)
- `.chezmoitemplates/aliases_ps1` contains `Set-Alias -Name g -Value gk` immediately after the `gk` function
- The `gk` function includes guard clauses for "GitKraken not installed" and "not a git repo" — both emit `Write-Warning` and return early
- `chezmoi execute-template` renders the PowerShell profile containing both `gk` and `g` definitions

## Key Risks / Unknowns

None — the scope is a single-file addition following established patterns, with a clear zsh reference implementation and all PS-specific adaptations resolved during research.

## Verification Classes

- Contract verification: `chezmoi execute-template` on the PS profile template renders `gk` function and `g` alias; `grep` confirms both definitions in `aliases_ps1`
- Integration verification: none (would require Windows + GitKraken; out of scope for Linux CI)
- Operational verification: none
- UAT / human verification: manual test on Windows after `chezmoi apply` (next Windows session)

## Milestone Definition of Done

This milestone is complete only when all are true:

- `aliases_ps1` contains the `## GitKraken` section with `gk` function and `g` alias
- The `gk` function follows established `aliases_ps1` patterns (function body, then Set-Alias)
- `chezmoi execute-template` renders the PS profile with both definitions present
- `chezmoi apply --dry-run` produces no errors related to the change
- The implementation matches the zsh alias UX: opens project in new window, backgrounded, returns prompt immediately

## Requirement Coverage

- Covers: none (no active requirements — this is new scope beyond M001/M002)
- Partially covers: none
- Leaves for later: none
- Orphan risks: none

## Slices

- [x] **S01: Add gk function and g alias to aliases_ps1** `risk:low` `depends:[]`
  > After this: `aliases_ps1` contains a working `gk` function and `g` shorthand; `chezmoi execute-template` renders both in the PS profile; manual verification on Windows confirms GitKraken launches from any git repo

## Boundary Map

### S01

Produces:
- `## GitKraken` section in `.chezmoitemplates/aliases_ps1` — `gk` function + `Set-Alias -Name g -Value gk`

Consumes:
- nothing (first and only slice)
