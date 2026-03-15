---
estimated_steps: 3
estimated_files: 1
---

# T01: Rename and add OS conditional

**Slice:** S01 — OS-gate conditional-launcher in mise config
**Milestone:** M004-fqlkfh

## Description

Rename `dot_config/mise/config.toml` to `dot_config/mise/config.toml.tmpl` and wrap the `"github:Mayurifag/conditional-launcher" = "latest"` entry in a `{{- if eq .chezmoi.os "linux" }} ... {{- end }}` conditional block. All other tool entries remain unconditional.

## Steps

1. `git mv dot_config/mise/config.toml dot_config/mise/config.toml.tmpl`
2. Edit `dot_config/mise/config.toml.tmpl`: wrap the `conditional-launcher` line in `{{- if eq .chezmoi.os "linux" }}` / `{{- end }}` using leading-dash trim markers (identical pattern to `exact_zsh/20-exports.zsh.tmpl`)
3. Run `chezmoi cat dot_config/mise/config.toml` to confirm rendered output contains all tools and is valid TOML

## Must-Haves

- [ ] File renamed from `.toml` to `.toml.tmpl`
- [ ] `conditional-launcher` line wrapped in Linux-only conditional
- [ ] All other 11 tool entries remain unconditional
- [ ] Trim markers (`{{-`) placed correctly: leading dash on both `if` and `end` tags

## Verification

- `ls dot_config/mise/config.toml.tmpl` — file exists
- `! ls dot_config/mise/config.toml 2>/dev/null` — old file gone
- `chezmoi cat dot_config/mise/config.toml | grep -c conditional-launcher` → `1` (on Linux)
- `chezmoi cat dot_config/mise/config.toml | grep -c yawn` → `1`

## Inputs

- `dot_config/mise/config.toml` — current plain TOML file with 12 tool entries under `[tools]`
- Research whitespace analysis — trim-marker pattern: `{{- if ... }}` / `{{- end }}`

## Expected Output

- `dot_config/mise/config.toml.tmpl` — chezmoi template with `conditional-launcher` gated to Linux only
