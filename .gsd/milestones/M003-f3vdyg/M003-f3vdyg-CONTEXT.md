# M003-f3vdyg: GitKraken PS Alias

**Gathered:** 2026-03-15
**Status:** Queued — pending auto-mode execution

## Project Description

Add `gk` (and its `g` shorthand) to the PowerShell aliases fragment so Windows PowerShell can launch GitKraken from the current project directory — matching the behaviour already present in zsh/bash via `aliases_posix`.

## Why This Milestone

zsh has `alias gk='(eval "gitkraken --new-window -p \"$(git rev-parse --show-toplevel)\" -l /dev/null >/dev/null 2>&1 &")'` and `alias g='gk'`. PowerShell has neither. The fragment infrastructure from M001 makes this a one-file addition.

## User-Visible Outcome

### When this milestone is complete, the user can:

- Type `gk` in a PowerShell session inside any git repo and have GitKraken open that project in a new window, backgrounded
- Type `g` as a shorthand for `gk` in PowerShell, matching zsh muscle memory

### Entry point / environment

- Entry point: PowerShell session (`pwsh`) in a git repo directory
- Environment: Windows local dev — `chezmoi apply` deploys the rendered profile
- Live dependencies involved: GitKraken (installed at `$env:LOCALAPPDATA\gitkraken\app-*\gitkraken.exe`)

## Completion Class

- Contract complete means: `aliases_ps1` template fragment contains working `gk` and `g` definitions
- Integration complete means: `chezmoi apply` on Windows renders a PS profile where `gk` and `g` invoke GitKraken with `--path` set to the git root of the current directory
- Operational complete means: none

## Final Integrated Acceptance

To call this milestone complete, we must prove:

- `chezmoi apply` on Windows produces a PS profile containing `gk` and `g` function definitions
- Running `gk` inside a git repo from PowerShell opens GitKraken at that project's root, backgrounded (no terminal block)
- `g` is an alias for `gk`

## Risks and Unknowns

- GitKraken install path uses versioned subdirs (`app-*`) — the function must glob to find the newest one at runtime; no single stable path exists
- `Start-Job` or `Start-Process -WindowStyle Hidden` needed for background launch — `&` alone in PS blocks until exit
- `git rev-parse --show-toplevel` returns POSIX-style paths on Windows; GitKraken may or may not accept them — may need `Convert-Path` or native path

## Existing Codebase / Prior Art

- `exact_zsh/40-aliases.zsh.tmpl` — zsh source of `gk`/`g` aliases; PowerShell equivalent should mirror the UX (open project, new window, no terminal block)
- `.chezmoitemplates/aliases_ps1` — fragment where `gk` and `g` PS functions will be added; pattern is established for all other PS aliases
- `Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl` — consumes `aliases_ps1`; no change needed here

> See `.gsd/DECISIONS.md` for all architectural and pattern decisions — it is an append-only register; read it during planning, append to it during execution.

## Relevant Requirements

- None registered — new scope beyond M001/M002.

## Scope

### In Scope

- `gk` PS function in `.chezmoitemplates/aliases_ps1`: glob latest `$env:LOCALAPPDATA\gitkraken\app-*\gitkraken.exe`, call with `--path` set to git root of cwd, launch backgrounded
- `g` shorthand (`Set-Alias -Name g -Value gk`) in `aliases_ps1`

### Out of Scope / Non-Goals

- Adding GitKraken to PATH (versioned subdirs make this impractical without a shim)
- Linux/macOS changes — `gk`/`g` already work there
- Any change to `aliases_posix` — zsh/bash already have the alias
- `git_bash` `.bashrc` — Git Bash on Windows already inherits `aliases_posix` which includes `gk`

## Technical Constraints

- GitKraken is installed under `$env:LOCALAPPDATA\gitkraken\app-*\` with versioned directories — must glob at invocation time
- PowerShell backgrounding: use `Start-Process` (not `&`) to truly detach the process
- `git rev-parse --show-toplevel` may return a POSIX-style path (`/c/Users/...`) in PS — if GitKraken requires a Windows path, use `(git rev-parse --show-toplevel) | Convert-Path` or `Resolve-Path`
- Must not block the terminal — GitKraken must open and PS prompt must return immediately

## Integration Points

- `GitKraken` — Windows native app; launched via `Start-Process` with `--path` flag pointing to git repo root
- `git` — used to resolve `--show-toplevel`; available on Windows via Git for Windows (which also provides Git Bash)

## Open Questions

- None — scope is tight and the zsh reference implementation makes intent clear.
