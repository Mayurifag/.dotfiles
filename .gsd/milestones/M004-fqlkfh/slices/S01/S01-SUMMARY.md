---
id: S01
parent: M004-fqlkfh
milestone: M004-fqlkfh
provides:
  - dot_config/mise/config.toml.tmpl with conditional-launcher gated to Linux
requires: []
affects: []
key_files:
  - dot_config/mise/config.toml.tmpl
key_decisions:
  - D014: rename to .toml.tmpl and OS-gate conditional-launcher
  - D015: single slice for M004-fqlkfh (rename + conditional in one pass)
patterns_established:
  - Leading-dash trim markers {{- if eq .chezmoi.os "linux" }} / {{- end }} around single TOML tool line
observability_surfaces:
  - none
drill_down_paths:
  - .gsd/milestones/M004-fqlkfh/slices/S01/tasks/T01-SUMMARY.md
  - .gsd/milestones/M004-fqlkfh/slices/S01/tasks/T02-SUMMARY.md
duration: ~6m
verification_result: passed
completed_at: 2026-03-15
---

# S01: OS-gate conditional-launcher in mise config

**`dot_config/mise/config.toml` renamed to `.toml.tmpl`; `conditional-launcher` wrapped in a Linux-only `{{- if eq .chezmoi.os "linux" }}` conditional block; all 12 tools render on Linux, 11 on non-Linux; `chezmoi apply --dry-run` produces zero errors.**

## What Happened

Two tasks, both complete:

**T01 (rename + edit):** Ran `git mv dot_config/mise/config.toml dot_config/mise/config.toml.tmpl`, then wrapped the `"github:Mayurifag/conditional-launcher" = "latest"` entry with `{{- if eq .chezmoi.os "linux" }}` / `{{- end }}` using leading-dash trim markers — the same pattern used in `exact_zsh/20-exports.zsh.tmpl`. All 11 other tool entries remain unconditional.

**T02 (verify):** Pure verification. Confirmed rendered TOML contains all 12 tools on Linux and that `chezmoi apply --dry-run` produces zero errors.

## Verification

| Check | Expected | Actual | Result |
|---|---|---|---|
| `ls dot_config/mise/config.toml.tmpl` | exists | exists | ✅ |
| `ls dot_config/mise/config.toml` | absent | absent | ✅ |
| `chezmoi cat ~/.config/mise/config.toml \| grep -c conditional-launcher` | 1 | 1 | ✅ |
| `chezmoi cat ~/.config/mise/config.toml \| grep -c yawn` | 1 | 1 | ✅ |
| `chezmoi apply --dry-run --force 2>&1 \| grep -i error \| grep -v 'ejson\|decrypt' \| wc -l` | 0 | 0 | ✅ |
| Rendered TOML is syntactically valid (no blank lines in `[tools]`) | valid | valid | ✅ |

Rendered output on Linux (13 lines):

```toml
[tools]
node = "lts"
go = "latest"
python = "latest"
rust = "latest"
ruby = "latest"
usage = "latest"
uv = "latest"
bun = "latest"
chezmoi = "latest"
claude-code = "latest"
"github:Mayurifag/yawn" = "latest"
"github:Mayurifag/conditional-launcher" = "latest"
```

## Deviations

`chezmoi cat <source-path>` is not addressable for `.tmpl` files — must use the target path `chezmoi cat ~/.config/mise/config.toml` to render the template. The task plan's verification command referenced the source-relative path; the target-path equivalent was used instead. Same result, different invocation. This is expected chezmoi behaviour.

## Known Limitations

None. The template is complete and correct for both Linux and non-Linux branches.

## Follow-ups

None.

## Files Created/Modified

- `dot_config/mise/config.toml.tmpl` — renamed from `.toml`, added Linux-only conditional around `conditional-launcher`

## Forward Intelligence

### What the next slice should know
- This is the only slice in M004-fqlkfh — milestone is complete.
- The `chezmoi cat` verification command requires the target path (`~/.config/mise/config.toml`), not the source path (`dot_config/mise/config.toml`), due to how chezmoi handles `.tmpl` resolution.

### What's fragile
- Nothing fragile — TOML entry-per-line format with no commas makes single-line template conditionals safe.

### Authoritative diagnostics
- `chezmoi cat ~/.config/mise/config.toml` — renders the template against current OS; inspect for correct tool list.
- `chezmoi apply --dry-run --force 2>&1 | grep -i error | grep -v 'ejson\|decrypt'` — confirms no template parse or apply errors.

### What assumptions changed
- D009 (keep config plain TOML, no OS-gating) was superseded for `conditional-launcher` specifically — D014 records the reversal. `claude-code` remains unconditional (cross-platform); `conditional-launcher` is Linux-only.
