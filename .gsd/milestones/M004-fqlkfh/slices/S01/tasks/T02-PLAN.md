---
estimated_steps: 2
estimated_files: 0
---

# T02: Verify rendered output and dry-run

**Slice:** S01 — OS-gate conditional-launcher in mise config
**Milestone:** M004-fqlkfh

## Description

Verify that the template renders correctly on the current OS (Linux) and that `chezmoi apply --dry-run` produces no new errors. This is pure verification — no files are modified.

## Steps

1. Run `chezmoi cat dot_config/mise/config.toml` and confirm output contains all 12 tools including `conditional-launcher`, with valid TOML syntax
2. Run `chezmoi apply --dry-run --force 2>&1 | grep -i error | grep -v 'ejson\|decrypt' | wc -l` and confirm result is `0`

## Must-Haves

- [ ] Rendered output contains all 12 tool entries on Linux
- [ ] No TOML syntax issues (no blank lines in `[tools]`, no merged lines)
- [ ] `chezmoi apply --dry-run` produces zero new errors

## Verification

- `chezmoi cat dot_config/mise/config.toml | wc -l` — should be ~14 lines (header + 12 tools)
- `chezmoi apply --dry-run --force 2>&1 | grep -i error | grep -v 'ejson\|decrypt' | wc -l` → `0`

## Inputs

- `dot_config/mise/config.toml.tmpl` — template created in T01

## Expected Output

- No files modified — verification-only task
- Confirmation that rendered TOML is correct and dry-run is clean
