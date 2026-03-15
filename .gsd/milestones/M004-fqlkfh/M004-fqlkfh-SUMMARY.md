---
id: M004-fqlkfh
provides:
  - dot_config/mise/config.toml.tmpl with conditional-launcher gated to Linux only
key_decisions:
  - D014: rename dot_config/mise/config.toml → .toml.tmpl and OS-gate conditional-launcher (supersedes D009 for this entry)
  - D015: single slice for M004-fqlkfh (rename + conditional in one pass)
patterns_established:
  - Leading-dash trim markers {{- if eq .chezmoi.os "linux" }} / {{- end }} around a single TOML tool entry
observability_surfaces:
  - none
requirement_outcomes: []
duration: ~6m
verification_result: passed
completed_at: 2026-03-15
---

# M004-fqlkfh: Mise Config OS Gating

**`dot_config/mise/config.toml` converted to a chezmoi template; `conditional-launcher` is now Linux-only; all 12 tools render on Linux, 11 on non-Linux; `chezmoi apply --dry-run` produces zero errors.**

## What Happened

Single slice (S01), two tasks:

**T01 (rename + edit):** `dot_config/mise/config.toml` was renamed to `dot_config/mise/config.toml.tmpl` via `git mv`. The `"github:Mayurifag/conditional-launcher" = "latest"` entry was wrapped in `{{- if eq .chezmoi.os "linux" }}` / `{{- end }}` using leading-dash trim markers — the same pattern established in `exact_zsh/20-exports.zsh.tmpl`. All 11 other tool entries remain unconditional.

**T02 (verify):** Confirmed rendered TOML on Linux contains all 12 tools with no blank lines in `[tools]`, and that `chezmoi apply --dry-run` produces zero errors.

The change is minimal and surgical: one file renamed, two template directive lines inserted around a single TOML entry. No other files touched.

## Cross-Slice Verification

All success criteria from the roadmap were verified against live state:

| Criterion | Expected | Actual | Result |
|---|---|---|---|
| `dot_config/mise/config.toml.tmpl` exists | exists | exists | ✅ |
| `dot_config/mise/config.toml` absent | absent | absent | ✅ |
| `chezmoi cat ~/.config/mise/config.toml \| grep -c conditional-launcher` | 1 | 1 | ✅ |
| `chezmoi cat ~/.config/mise/config.toml \| grep -c yawn` | 1 | 1 | ✅ |
| `chezmoi apply --dry-run --force 2>&1 \| grep -i error \| grep -v 'ejson\|decrypt'` | 0 lines | 0 lines | ✅ |
| Rendered TOML valid — no blank lines in `[tools]`, no trailing commas | valid | valid | ✅ |

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

Non-Linux branch omits the `conditional-launcher` line and renders a clean 12-line `[tools]` section.

## Requirement Changes

No active requirements were tracked for this milestone — it is a maintenance/correctness fix. No requirement status transitions.

## Forward Intelligence

### What the next milestone should know
- All milestones M001–M004-fqlkfh are complete. The project is in maintenance state.
- `chezmoi cat` verification requires the target path (`~/.config/mise/config.toml`), not the source path (`dot_config/mise/config.toml.tmpl`) — chezmoi resolves `.tmpl` only via the target.
- `conditional-launcher` is Linux-only in mise; `yawn` and all other tools are unconditional.

### What's fragile
- Nothing fragile — TOML entry-per-line format with no commas makes single-line template conditionals safe. Adding a new Linux-only tool follows the identical pattern.

### Authoritative diagnostics
- `chezmoi cat ~/.config/mise/config.toml` — renders the template against current OS; inspect for correct tool list.
- `chezmoi apply --dry-run --force 2>&1 | grep -i error | grep -v 'ejson\|decrypt'` — confirms no template parse or apply errors.

### What assumptions changed
- D009 (keep config plain TOML, no OS-gating) was superseded for `conditional-launcher` specifically — D014 records the reversal. `claude-code` remains unconditional (cross-platform); `conditional-launcher` is Linux-only.

## Files Created/Modified

- `dot_config/mise/config.toml.tmpl` — renamed from `.toml`; `conditional-launcher` entry wrapped in Linux-only conditional block
