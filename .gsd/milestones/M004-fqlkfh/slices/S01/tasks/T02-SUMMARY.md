---
id: T02
parent: S01
milestone: M004-fqlkfh
provides:
  - Confirmed rendered TOML contains all 12 tools on Linux
  - Confirmed chezmoi apply --dry-run produces zero new errors
key_files:
  - dot_config/mise/config.toml.tmpl
key_decisions:
  - none
patterns_established:
  - none
observability_surfaces:
  - none
duration: ~1min
verification_result: passed
completed_at: 2026-03-15
blocker_discovered: false
---

# T02: Verify rendered output and dry-run

**`chezmoi cat ~/.config/mise/config.toml` renders all 12 tools including `conditional-launcher` on Linux; `chezmoi apply --dry-run` produces zero errors.**

## What Happened

Pure verification task — no files modified. Both checks from the task plan were run against the template created in T01.

`chezmoi cat dot_config/mise/config.toml` (source path) is not directly addressable after renaming to `.tmpl`, but `chezmoi cat ~/.config/mise/config.toml` (target path) correctly renders the template and shows all 12 tools.

## Verification

All slice-level checks passed:

| Check | Expected | Actual | Result |
|---|---|---|---|
| `chezmoi cat ~/.config/mise/config.toml \| wc -l` | ~14 | 13 | ✅ (header + 12 tools) |
| `chezmoi cat ~/.config/mise/config.toml \| grep -c conditional-launcher` | 1 | 1 | ✅ |
| `chezmoi cat ~/.config/mise/config.toml \| grep -c yawn` | 1 | 1 | ✅ |
| `chezmoi apply --dry-run --force 2>&1 \| grep -i error \| grep -v 'ejson\|decrypt' \| wc -l` | 0 | 0 | ✅ |

Rendered TOML is syntactically valid — no blank lines in `[tools]`, no merged lines.

## Diagnostics

- `chezmoi cat ~/.config/mise/config.toml` — inspect rendered output on current OS
- Template source: `dot_config/mise/config.toml.tmpl`

## Deviations

`chezmoi cat <source-path>` with the `.tmpl` extension returns "not managed" — must use the target path `chezmoi cat ~/.config/mise/config.toml` to render the template. This is expected chezmoi behaviour and not a deviation from intent.

## Known Issues

none

## Files Created/Modified

- No files modified — verification-only task
