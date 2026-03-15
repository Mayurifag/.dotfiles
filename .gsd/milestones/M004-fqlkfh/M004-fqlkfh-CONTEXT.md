# M004-fqlkfh: Mise Config OS Gating

**Gathered:** 2026-03-15
**Status:** Queued — pending auto-mode execution

## Project Description

Convert `dot_config/mise/config.toml` to a chezmoi template so that `"github:Mayurifag/conditional-launcher"` is only installed on Linux. All other tools remain unconditional.

## Why This Milestone

`conditional-launcher` is a Linux-only tool — installing it on Windows via mise is either a no-op or a failure. The existing template infrastructure (chezmoi OS conditions) makes this a straightforward one-file conversion.

## User-Visible Outcome

### When this milestone is complete, the user can:

- Run `chezmoi apply` on Windows without mise attempting to install `conditional-launcher`
- Run `chezmoi apply` on Linux and have `conditional-launcher` installed as before

### Entry point / environment

- Entry point: `chezmoi apply` on any OS
- Environment: local dev (Linux or Windows)
- Live dependencies involved: mise, `github:Mayurifag/conditional-launcher`

## Completion Class

- Contract complete means: `dot_config/mise/config.toml.tmpl` renders correctly — Linux output includes `conditional-launcher`, Windows output omits it
- Integration complete means: `chezmoi apply` on both OSes produces a valid `~/.config/mise/config.toml` that mise can parse
- Operational complete means: none

## Final Integrated Acceptance

To call this milestone complete, we must prove:

- On Linux: rendered `~/.config/mise/config.toml` contains `"github:Mayurifag/conditional-launcher" = "latest"`
- On Windows: rendered `~/.config/mise/config.toml` does not contain `conditional-launcher`
- All other tools (`node`, `go`, `python`, `rust`, `ruby`, `usage`, `uv`, `bun`, `chezmoi`, `"github:Mayurifag/yawn"`) remain present on both OSes

## Risks and Unknowns

- TOML validity after template rendering — chezmoi templating must not leave trailing commas or blank lines that break TOML parsing; conditional block placement matters
- `dot_config/mise/` directory is not prefixed `exact_` — no removal concern, just a rename

## Existing Codebase / Prior Art

- `dot_config/mise/config.toml` — file to rename to `.tmpl` and add OS condition around `conditional-launcher` entry
- `dot_bashrc.tmpl` — established pattern: `{{- if eq .chezmoi.os "linux" }} ... {{- end }}`
- `dot_gitconfig.tmpl`, `exact_zsh/20-exports.zsh.tmpl` — further examples of the same `chezmoi.os` gating pattern

> See `.gsd/DECISIONS.md` for all architectural and pattern decisions — it is an append-only register; read it during planning, append to it during execution.

## Relevant Requirements

- None registered — maintenance/correctness fix, not new user-visible scope.

## Scope

### In Scope

- Rename `dot_config/mise/config.toml` → `dot_config/mise/config.toml.tmpl`
- Wrap `"github:Mayurifag/conditional-launcher" = "latest"` in `{{- if eq .chezmoi.os "linux" }} ... {{- end }}`
- Verify rendered TOML is valid on both OS branches

### Out of Scope / Non-Goals

- Gating any other tool (`yawn` stays unconditional — it is cross-platform)
- Adding new tools to the mise config
- Changes to any other file

## Technical Constraints

- TOML does not allow trailing commas — the conditional block must not leave a dangling comma when omitted on Windows
- The `[tools]` section uses one entry per line (`key = "value"`), so wrapping a single line in a conditional is straightforward and won't affect surrounding entries
- No `chezmoi:line-endings` directive needed — `~/.config/mise/config.toml` deploys on Linux (LF) and Windows (chezmoi handles line endings per OS default)

## Integration Points

- `mise` — reads `~/.config/mise/config.toml` at every invocation; invalid TOML breaks all mise commands
- `chezmoi` — template rendered at `chezmoi apply` time; OS detected via `.chezmoi.os`

## Open Questions

- None.
