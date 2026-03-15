---
id: T01
parent: S01
milestone: M004-fqlkfh
provides:
  - dot_config/mise/config.toml.tmpl with conditional-launcher gated to Linux
key_files:
  - dot_config/mise/config.toml.tmpl
key_decisions:
  - D014: rename to .toml.tmpl and OS-gate conditional-launcher (already recorded)
patterns_established:
  - Leading-dash trim markers {{- if eq .chezmoi.os "linux" }} / {{- end }} around single tool line
observability_surfaces:
  - none
duration: 5m
verification_result: passed
completed_at: 2026-03-15
blocker_discovered: false
---

# T01: Rename and add OS conditional

**`dot_config/mise/config.toml` renamed to `.toml.tmpl` with `conditional-launcher` wrapped in a Linux-only `{{- if eq .chezmoi.os "linux" }}` conditional block.**

## What Happened

Ran `git mv dot_config/mise/config.toml dot_config/mise/config.toml.tmpl`, then edited the new template to wrap `"github:Mayurifag/conditional-launcher" = "latest"` with `{{- if eq .chezmoi.os "linux" }}` / `{{- end }}` using leading-dash trim markers (matching the pattern in `exact_zsh/20-exports.zsh.tmpl`). All 11 other tool entries remain unconditional.

## Verification

- `ls dot_config/mise/config.toml.tmpl` — file exists ✓
- `! ls dot_config/mise/config.toml 2>/dev/null` — old file gone ✓
- `chezmoi cat ~/.config/mise/config.toml | grep -c conditional-launcher` → `1` ✓
- `chezmoi cat ~/.config/mise/config.toml | grep -c yawn` → `1` ✓
- `chezmoi apply --dry-run --force 2>&1 | grep -i error | grep -v 'ejson\|decrypt' | wc -l` → `0` ✓

## Diagnostics

`chezmoi cat ~/.config/mise/config.toml` shows rendered TOML with all 12 tools on Linux; on non-Linux the `conditional-launcher` line is omitted by the template engine.

## Deviations

`chezmoi cat dot_config/mise/config.toml` (source-relative path) is not supported — task plan's verification command requires the destination path `~/.config/mise/config.toml`. Same result, different invocation.

## Known Issues

none

## Files Created/Modified

- `dot_config/mise/config.toml.tmpl` — renamed from `.toml`, added Linux-only conditional around `conditional-launcher`
