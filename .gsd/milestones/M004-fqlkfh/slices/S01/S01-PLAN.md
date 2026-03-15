# S01: OS-gate conditional-launcher in mise config

**Goal:** `dot_config/mise/config.toml` becomes a chezmoi template that wraps `conditional-launcher` in a Linux-only conditional block.
**Demo:** `chezmoi cat dot_config/mise/config.toml` on Linux includes `conditional-launcher`; simulated Windows rendering omits it; `chezmoi apply --dry-run` produces no errors.

## Must-Haves

- Rename `dot_config/mise/config.toml` → `dot_config/mise/config.toml.tmpl`
- Wrap `"github:Mayurifag/conditional-launcher" = "latest"` in `{{- if eq .chezmoi.os "linux" }} ... {{- end }}`
- All other tool entries remain unconditional
- Rendered TOML is valid on both OS branches (no blank lines, no merged lines)

## Verification

- `chezmoi cat dot_config/mise/config.toml` — must contain all 12 tools including `conditional-launcher` (on Linux)
- `chezmoi cat dot_config/mise/config.toml | grep -c conditional-launcher` → `1`
- `chezmoi cat dot_config/mise/config.toml | grep -c yawn` → `1`
- `chezmoi apply --dry-run --force 2>&1 | grep -i error | grep -v 'ejson\|decrypt' | wc -l` → `0`

## Tasks

- [x] **T01: Rename and add OS conditional** `est:5m`
  - Why: This is the entire implementation — rename file and add template logic
  - Files: `dot_config/mise/config.toml` → `dot_config/mise/config.toml.tmpl`
  - Do: `git mv dot_config/mise/config.toml dot_config/mise/config.toml.tmpl`; wrap `"github:Mayurifag/conditional-launcher" = "latest"` in `{{- if eq .chezmoi.os "linux" }}` / `{{- end }}` using the same trim-marker pattern as `exact_zsh/20-exports.zsh.tmpl`
  - Verify: `chezmoi cat dot_config/mise/config.toml` shows valid TOML with all tools present
  - Done when: file renamed, conditional block in place, `chezmoi cat` output is correct

- [x] **T02: Verify rendered output and dry-run** `est:2m`
  - Why: Confirm template renders correctly and doesn't break chezmoi apply
  - Files: (none modified — verification only)
  - Do: Run `chezmoi cat dot_config/mise/config.toml` and inspect; run `chezmoi apply --dry-run --force` and check for errors
  - Verify: `chezmoi apply --dry-run --force 2>&1 | grep -i error | grep -v 'ejson\|decrypt' | wc -l` → `0`
  - Done when: rendered TOML is valid, all tools present, dry-run clean

## Files Likely Touched

- `dot_config/mise/config.toml` → `dot_config/mise/config.toml.tmpl`
