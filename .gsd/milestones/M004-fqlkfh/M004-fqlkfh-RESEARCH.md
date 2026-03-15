# M004-fqlkfh — Research

**Date:** 2026-03-15

## Summary

This is a minimal one-file change: rename `dot_config/mise/config.toml` → `dot_config/mise/config.toml.tmpl` and wrap the `conditional-launcher` entry in `{{- if eq .chezmoi.os "linux" }} ... {{- end }}`. The existing codebase has this exact pattern in at least three places (`dot_bashrc.tmpl`, `exact_zsh/20-exports.zsh.tmpl`, `dot_gitconfig.tmpl`), so no new infrastructure is needed.

The critical constraint is TOML validity: TOML uses `key = "value"` entries one per line with no commas, so a missing entry on Windows leaves no dangling syntax. The only risk is whitespace: careless use of template trim markers (`{{-` / `-}}`) could merge two lines into one or leave blank lines. The correct markers are `{{- if ... }}` (trim before, keep after) and `{{- end }}` (trim before, keep after), which yields clean single-entry lines on both branches with no blank lines.

Chezmoi detects `.tmpl` suffix and processes the file at `chezmoi apply` time. The rename from `.toml` to `.toml.tmpl` is sufficient — no `.chezmoiignore` or `exact_` prefix changes required.

## Recommendation

Rename the file and apply the conditional block using the `{{- if eq .chezmoi.os "linux" }} / {{- end }}` pattern — identical to `20-exports.zsh.tmpl` line 1. Place the conditional block after the last unconditional entry (`"github:Mayurifag/yawn"`). The resulting template renders as:

**Linux:**
```toml
"github:Mayurifag/yawn" = "latest"
"github:Mayurifag/conditional-launcher" = "latest"
```

**Windows:**
```toml
"github:Mayurifag/yawn" = "latest"
```

Both branches are valid TOML. No other files need to change.

## Don't Hand-Roll

| Problem | Existing Solution | Why Use It |
|---------|------------------|------------|
| OS-conditional file content | `{{- if eq .chezmoi.os "linux" }} ... {{- end }}` in `.tmpl` files | Already used in `20-exports.zsh.tmpl`, `dot_bashrc.tmpl`, `dot_gitconfig.tmpl` — idiomatic for this repo |
| Verifying rendered output without applying | `chezmoi cat dot_config/mise/config.toml` | Shows what chezmoi would write without touching the filesystem |

## Existing Code and Patterns

- `exact_zsh/20-exports.zsh.tmpl` (line 1) — `{{ if eq .chezmoi.os "linux" -}}` / `{{- end }}` — exact pattern to follow for the `if` guard; note the `-` placement matches the established convention
- `dot_bashrc.tmpl` (line 34) — `{{- if eq .chezmoi.os "windows" }}` — confirms OS gating syntax; this project uses both linux and windows conditions
- `dot_config/mise/config.toml` — current file: 13 entries under `[tools]`, one per line, no commas; safe to wrap any single line in a conditional

## Whitespace Analysis

The correct trim-marker combination for a conditional line in a flat list:

```
"github:Mayurifag/yawn" = "latest"
{{- if eq .chezmoi.os "linux" }}
"github:Mayurifag/conditional-launcher" = "latest"
{{- end }}
```

- `{{-` on `if`: trims the `\n` before the tag → yawn entry ends immediately before the next real line
- `}}` (no trailing dash) on `if`: preserves the `\n` after the tag → conditional-launcher starts on its own line
- `{{-` on `end`: trims the `\n` before the tag → no trailing blank line on Linux; on Windows eats whitespace in the empty buffer
- `}}` on `end`: preserves final `\n` at EOF

Result on Linux: `..."yawn" = "latest"\n"conditional-launcher" = "latest"\n` ✓  
Result on Windows: `..."yawn" = "latest"\n` ✓

## Common Pitfalls

- **Wrong dash placement on `if` tag** — using `{{ if ... -}}` (trailing dash) instead of `{{- if ... }}` (leading dash) trims the newline *after* the tag rather than before, causing the conditional-launcher line to be concatenated onto the yawn line on Linux. Always use `{{-` leading to trim the preceding newline.
- **Blank lines on Windows** — using `{{ if ... }}` without leading dash leaves a blank line where the conditional block was (the `{{ if }}` line itself emits a newline). The `{{-` leading dash prevents this.
- **Missing final newline** — ensure the file ends with `\n` after `{{- end }}` to avoid chezmoi diffs on every apply.
- **Double-checking with `chezmoi cat`** — always verify rendered output with `chezmoi cat dot_config/mise/config.toml` after the rename; invalid TOML breaks all mise commands silently.

## Open Risks

- None. TOML entry-per-line format with no commas makes single-line conditionals safe. The established chezmoi template patterns in this repo cover this exact case.

## Skills Discovered

| Technology | Skill | Status |
|------------|-------|--------|
| chezmoi | (built-in patterns, no external skill needed) | n/a |
| mise | (config format is plain TOML, no skill needed) | n/a |

## Sources

- `exact_zsh/20-exports.zsh.tmpl` — primary pattern reference for `{{- if eq .chezmoi.os "linux" }}` syntax (codebase)
- `dot_bashrc.tmpl` — confirms `.chezmoiignore`-free OS gating approach (codebase)
- `.gsd/DECISIONS.md` D009 — confirms prior decision to keep mise config plain; this milestone supersedes that for `conditional-launcher` specifically
