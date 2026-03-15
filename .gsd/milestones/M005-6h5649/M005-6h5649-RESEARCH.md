# M005-6h5649 — Research

**Date:** 2026-03-15

## Summary

This milestone is three small, independent edits across two files: `.chezmoitemplates/aliases_ps1` (two changes: `gp` conditional and `free` function) and `Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl` (`czapply` re-source). All three sites are precisely located; no architectural decisions are required — just correct PS syntax.

The `gp` change is the only one with a meaningful syntax trap. The POSIX version does `$(git symbolic-ref --short HEAD)` inline inside a string, but in PS7 you cannot embed command substitution inline inside another command's arguments the same way. The existing stub already demonstrates the correct PS pattern: `(git symbolic-ref --short HEAD)` works as a subexpression in argument position. The conditional check (`git config "branch.<name>.merge"`) requires capturing the branch name as a variable first — `$branch = git symbolic-ref --short HEAD` — then `git config "branch.$branch.merge"`. Using `$()` (subexpression) inside a string literal for the config key is the natural PS idiom; this will work correctly.

For `free`: `Get-CimInstance Win32_OperatingSystem` provides `TotalVisibleMemorySize` and `FreePhysicalMemory` in **KB** (not bytes). Dividing by 1024 gives MB. `Get-CimInstance Win32_PhysicalMemory | Measure-Object Capacity -Sum` gives total installed RAM in bytes — divide by 1MB (1048576) for MB. A clean one-liner display matching `free -m` column layout (total / used / free) is achievable with `Write-Host`. The `czapply` change is trivially `. $PROFILE` on a new line inside the function body.

## Recommendation

Implement all three in a single pass (single slice, single task) — they're all in two files, all low-risk, and the milestone is small enough that decomposing further adds ceremony. Implement `gp` conditional with a captured variable for the branch name. Place `free` in the existing `## System utilities` section after `myip`. Add `. $PROFILE` as the last line of `czapply`.

## Don't Hand-Roll

| Problem | Existing Solution | Why Use It |
|---------|------------------|------------|
| Check if branch has upstream in PS | `git config "branch.$branch.merge"` (same git plumbing as POSIX) | Matches POSIX reference implementation exactly; no PS-specific API needed |
| Memory stats on Windows | `Get-CimInstance Win32_OperatingSystem` + `Win32_PhysicalMemory` | Windows-native WMI; always present in PS7; no external dependency |
| Re-source profile after chezmoi apply | `. $PROFILE` | `$PROFILE` is always defined in PS7; idiomatic PS re-source |

## Existing Code and Patterns

- `.chezmoitemplates/aliases_ps1` line 40–41 — `gp` stub with comment `# gp: stub — pushes with -u to set upstream; full conditional logic in Phase 2`; replace both lines with the full conditional
- `.chezmoitemplates/aliases_ps1` lines 100–113 (`## System utilities`) — `df`, `du`, `myip` pattern; `free` fits as a function after `myip`, same section
- `.chezmoitemplates/aliases_posix` line `alias gp=...` — reference implementation: `[[ -z $(git config "branch.$(git symbolic-ref --short HEAD).merge") ]] && git push -u origin $(git symbolic-ref --short HEAD) || git push`
- `Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl` line 24 — `function czapply { chezmoi apply -v }` — add `. $PROFILE` as second statement inside the braces; comment on line 23 will need updating too (it says "reload manually if needed" — that's no longer accurate)
- `chezmoi execute-template` — confirmed working on Linux for this template; renders `aliases_ps1` fragment correctly; use for post-change validation

## Common Pitfalls

- **Inline command substitution in PS string literals** — `"branch.$(git symbolic-ref --short HEAD).merge"` does NOT work in PS because `$()` inside a double-quoted string evaluates PS expressions, not shell commands. Capture the branch name first: `$branch = git symbolic-ref --short HEAD`, then use `"branch.$branch.merge"` in the string. The existing stub at line 41 already uses `(git symbolic-ref --short HEAD)` in argument position (not inside a string), which is fine — the config key lookup requires the string interpolation approach.
- **Win32_PhysicalMemory Capacity in bytes** — `Capacity` on `Win32_PhysicalMemory` is bytes; `TotalVisibleMemorySize` and `FreePhysicalMemory` on `Win32_OperatingSystem` are KB. Must divide correctly: physical total ÷ 1MB, OS fields ÷ 1024.
- **gp @args passthrough** — the existing stub passes `@args`; the replacement should omit `@args` since the POSIX version takes no args (it's a self-contained push command). Check existing PS functions — `gpf` does not pass `@args` either.
- **czapply comment on line 23** — the comment `# chezmoi apply — PS profile doesn't self-source; reload manually if needed` will be stale after the change. Update it to reflect that czapply now re-sources automatically.

## Open Risks

- `git symbolic-ref --short HEAD` on a detached HEAD returns an error exit code; both the current stub and the POSIX alias have this latent issue — not a regression, but worth noting the PS version should handle it the same way as the stub (silently, since git will error anyway on push).
- `gp` with `@args` removal: the stub includes `@args` but the POSIX alias does not accept extra args. Dropping `@args` is correct for parity, but is a minor behaviour change from the current stub. Not a risk for intended usage.
