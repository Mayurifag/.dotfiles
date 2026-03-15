# M004-fqlkfh: Mise Config OS Gating

**Vision:** `conditional-launcher` is only installed via mise on Linux; Windows `chezmoi apply` skips it cleanly.

## Success Criteria

- Rendered `~/.config/mise/config.toml` on Linux contains `"github:Mayurifag/conditional-launcher" = "latest"`
- Rendered `~/.config/mise/config.toml` on Windows does not contain `conditional-launcher`
- All other tools (`node`, `go`, `python`, `rust`, `ruby`, `usage`, `uv`, `bun`, `chezmoi`, `claude-code`, `"github:Mayurifag/yawn"`) remain present on both OSes
- `chezmoi cat dot_config/mise/config.toml` produces valid TOML parseable by mise

## Key Risks / Unknowns

None. TOML entry-per-line format with no commas makes single-line conditionals safe. The `{{- if eq .chezmoi.os "linux" }}` pattern is established in three other files in this repo.

## Verification Classes

- Contract verification: `chezmoi cat dot_config/mise/config.toml` — inspect rendered output for correct entries
- Integration verification: `chezmoi apply --dry-run` — confirm no errors from the template change
- Operational verification: none
- UAT / human verification: none

## Milestone Definition of Done

This milestone is complete only when all are true:

- `dot_config/mise/config.toml.tmpl` exists (old `.toml` removed)
- `chezmoi cat` on Linux shows all 12 tools including `conditional-launcher`
- `chezmoi cat` output without the conditional block shows all 11 tools excluding `conditional-launcher`
- `chezmoi apply --dry-run` produces no new errors
- Rendered output is valid TOML (no trailing commas, no merged lines, no blank lines in `[tools]`)

## Requirement Coverage

- Covers: none (no active requirements — this is a maintenance/correctness fix)
- Orphan risks: none

## Slices

- [x] **S01: OS-gate conditional-launcher in mise config** `risk:low` `depends:[]`
  > After this: `chezmoi cat dot_config/mise/config.toml` renders valid TOML with `conditional-launcher` present on Linux and absent on Windows; `chezmoi apply --dry-run` shows no errors

## Boundary Map

### S01

Produces:
- `dot_config/mise/config.toml.tmpl` — chezmoi template that conditionally includes `conditional-launcher` on Linux only

Consumes:
- nothing (first and only slice)
