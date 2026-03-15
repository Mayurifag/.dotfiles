# M005-6h5649: PowerShell Alias Parity

**Gathered:** 2026-03-15
**Status:** Queued — pending auto-mode execution

## Project Description

Close three parity gaps between `aliases_posix` and `aliases_ps1` that were deferred from M001:

1. **`gp` full logic** — the PS stub always runs `git push -u origin HEAD`; the POSIX version conditionally omits `-u` when an upstream tracking branch is already configured. Replace the stub with the full conditional.
2. **`free` function** — POSIX has `alias free='free -m'`; Windows has no equivalent. Add a PS function wrapping `Get-CimInstance Win32_PhysicalMemory` to display a concise memory summary.
3. **`czapply` re-source** — PS `czapply` currently runs `chezmoi apply -v` but does not re-source the profile. POSIX equivalents in both `aliases_posix` (zsh) and `dot_bashrc.tmpl` (bash) both re-source after apply. Add `. $PROFILE` after `chezmoi apply -v` in the PS profile's `czapply` function.

## Why This Milestone

The M001 fragment parity work explicitly deferred `gp` with a `# stub — full conditional logic in Phase 2` comment. `free` and `czapply` re-sourcing are small but real usability gaps. All three are low-risk, isolated changes to two already-established files.

## User-Visible Outcome

### When this milestone is complete, the user can:

- Run `gp` in PowerShell from a branch with an existing upstream and get `git push` (not `git push -u origin HEAD`) — matching zsh behaviour
- Run `gp` from a branch with no upstream and get `git push -u origin <branch>` — same as before
- Run `free` in PowerShell and see a concise physical memory summary (total / used / free in MB or GB)
- Run `czapply` in PowerShell and have the profile automatically re-sourced after `chezmoi apply -v` — no manual `. $PROFILE` step

### Entry point / environment

- Entry point: PowerShell session (`pwsh`) on Windows
- Environment: Windows local dev — `chezmoi apply` deploys the rendered profile
- Live dependencies involved: none beyond what's already present (git, chezmoi, WMI/CimInstance is Windows-native)

## Completion Class

- Contract complete means: `aliases_ps1` contains the correct `gp` implementation and `free` function; the PS profile `czapply` function includes `. $PROFILE`
- Integration complete means: `chezmoi execute-template` renders the profile with all three changes; `chezmoi apply --dry-run` produces no errors
- Operational complete means: none (Windows live testing not required for contract/integration validation)

## Final Integrated Acceptance

To call this milestone complete, we must prove:

- `grep` on `aliases_ps1` confirms `gp` no longer contains the stub comment and contains the upstream-check conditional
- `grep` on `aliases_ps1` confirms `free` function is present with CimInstance call
- `grep` on PS profile confirms `czapply` body contains `. $PROFILE`
- `chezmoi execute-template` renders all three correctly
- `chezmoi apply --dry-run` produces zero errors

## Risks and Unknowns

- PS `git config` quoting — `git config "branch.$((git symbolic-ref --short HEAD)).merge"` needs correct subexpression syntax in PS; `$(...)` is not POSIX shell here but `$((git symbolic-ref --short HEAD))` may need to be captured as a variable first for clarity
- `free` output format — no standard format required, just useful; CimInstance returns bytes, needs division to MB; rounding and formatting to match `free -m`-style columns is cosmetic but worth doing cleanly
- `. $PROFILE` in `czapply` — if chezmoi apply changes the profile, the re-source picks up the new version immediately, which is exactly the desired behaviour; no known risk

## Existing Codebase / Prior Art

- `.chezmoitemplates/aliases_ps1` — `gp` stub at line 41, `free` is absent; `## System utilities` section contains `df`/`du`/`myip`; `free` fits here
- `.chezmoitemplates/aliases_posix` — reference implementation for `gp` (`alias gp='[[ -z $(git config "branch.$(git symbolic-ref --short HEAD).merge") ]] && git push -u origin $(git symbolic-ref --short HEAD) || git push'`)
- `Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl` — `czapply` defined at bottom as `function czapply { chezmoi apply -v }`; add `. $PROFILE` inside this function body

> See `.gsd/DECISIONS.md` for all architectural and pattern decisions — it is an append-only register; read it during planning, append to it during execution.

## Relevant Requirements

- None registered — parity/maintenance work, no new requirement contracts needed.

## Scope

### In Scope

- Replace `gp` stub in `aliases_ps1` with full conditional: if `branch.<current>.merge` is empty → `git push -u origin <branch>`; else → `git push`
- Add `free` function to `## System utilities` section of `aliases_ps1`: wraps `Get-CimInstance Win32_PhysicalMemory`, sums capacity, computes used/free via `Get-CimInstance Win32_OperatingSystem`, outputs in MB
- Update `czapply` in `Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl` to add `. $PROFILE` after `chezmoi apply -v`

### Out of Scope / Non-Goals

- Replacing `df.exe`/`du.exe`/`grep.exe` with PS-native equivalents — Git-for-Windows dependency accepted (D-series decision in M001)
- Any changes to `aliases_posix`, `dot_bashrc.tmpl`, or zsh files
- Adding any other missing POSIX aliases beyond these three items

## Technical Constraints

- PS does not support `$()` command substitution inline inside strings the same way bash does — capture `git symbolic-ref --short HEAD` as a variable before using in `git config` lookup
- `Get-CimInstance Win32_OperatingSystem` provides `TotalVisibleMemorySize` and `FreePhysicalMemory` in KB — divide by 1024 for MB to match `free -m` units
- `czapply` re-source with `. $PROFILE` works because `$PROFILE` is always defined in PS7 sessions

## Integration Points

- `git` — `gp` calls `git symbolic-ref` and `git config`; both available via Git for Windows
- `Get-CimInstance` — Windows-native WMI cmdlet; always available in PS7 on Windows; no external dependency
- `chezmoi` — `czapply` calls `chezmoi apply -v` then re-sources; chezmoi must be on PATH (it is, via mise)

## Open Questions

- None.
