---
estimated_steps: 3
estimated_files: 1
---

# T01: Replace gp stub with full conditional

**Slice:** S01 — Implement gp conditional, free function, and czapply re-source
**Milestone:** M005-6h5649

## Description

Replace the `gp` stub in `.chezmoitemplates/aliases_ps1` (lines 40–41) with a full conditional function that matches the POSIX `gp` alias behaviour: check if the current branch has an upstream tracking branch configured; if yes, run `git push`; if no, run `git push -u origin <branch>`.

## Steps

1. Open `.chezmoitemplates/aliases_ps1` and locate lines 40–41 (stub comment + function)
2. Replace both lines with a multi-line `gp` function:
   - Capture `$branch = git symbolic-ref --short HEAD`
   - Check `git config "branch.$branch.merge"` — if non-empty, upstream exists
   - If upstream exists: `git push`
   - If no upstream: `git push -u origin $branch`
3. Drop `@args` — POSIX `gp` takes no arguments; parity requires the same

## Must-Haves

- [ ] `$branch` variable captured before string interpolation in `git config` key
- [ ] Conditional branches to `git push` (upstream exists) or `git push -u origin $branch` (no upstream)
- [ ] No `@args` passthrough
- [ ] Stub comment removed

## Verification

- `grep -c 'stub' .chezmoitemplates/aliases_ps1` returns 0
- `grep 'git config "branch\.\$branch\.merge"' .chezmoitemplates/aliases_ps1` matches
- `grep 'git push -u origin \$branch' .chezmoitemplates/aliases_ps1` matches
- `grep 'git push$' .chezmoitemplates/aliases_ps1` matches (bare push for upstream case)

## Inputs

- `.chezmoitemplates/aliases_ps1` lines 40–41 — current stub to replace
- `.chezmoitemplates/aliases_posix` line 22 — reference implementation: `[[ -z $(git config "branch.$(git symbolic-ref --short HEAD).merge") ]] && git push -u origin $(git symbolic-ref --short HEAD) || git push`

## Observability Impact

- **Inspection:** After applying, run `chezmoi execute-template < .chezmoitemplates/aliases_ps1 | grep -A8 'function gp'` to confirm the conditional block rendered correctly
- **Failure state:** If `git symbolic-ref --short HEAD` fails (detached HEAD), `$branch` will be empty and `git push -u origin ` will error — same behaviour as the POSIX alias; no special handling needed
- **No secrets** — template contains no credentials; no redaction constraints apply

## Expected Output

- `.chezmoitemplates/aliases_ps1` — `gp` function replaced with full conditional, stub comment removed
