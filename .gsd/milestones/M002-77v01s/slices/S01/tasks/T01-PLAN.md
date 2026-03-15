---
estimated_steps: 2
estimated_files: 1
---

# T01: Add claude-code to mise config

**Slice:** S01 — Mise-managed claude-code with cleanup
**Milestone:** M002-77v01s

## Description

Add `claude-code = "latest"` to the `[tools]` section of the chezmoi-managed mise global config. This is a plain TOML file — no template needed since `claude-code = "latest"` works identically on Linux and Windows (aqua backend on Linux/macOS, npm fallback on Windows via mise's built-in logic).

## Steps

1. Open `dot_config/mise/config.toml`
2. Add `claude-code = "latest"` to the `[tools]` section (alphabetical order preferred, after `chezmoi = "latest"`)
3. Save the file

## Must-Haves

- [ ] `claude-code = "latest"` present in `[tools]` section
- [ ] File remains valid TOML (no syntax errors)

## Verification

- `grep 'claude-code' dot_config/mise/config.toml` returns `claude-code = "latest"`
- `cat dot_config/mise/config.toml` shows the entry in `[tools]` block

## Inputs

- `dot_config/mise/config.toml` — existing mise global config with other tools

## Expected Output

- `dot_config/mise/config.toml` — updated with `claude-code = "latest"` in `[tools]`

## Observability Impact

This task has no runtime observability surface of its own — it is a static config change. Inspection signals:

- **Verify presence:** `grep 'claude-code' dot_config/mise/config.toml` must return `claude-code = "latest"`
- **Verify TOML validity:** `chezmoi apply --dry-run 2>&1 | grep -i error` must return empty
- **Downstream signal:** after `chezmoi apply && mise install`, `which claude` and `claude --version` are the live success indicators; absence means the entry is missing or mise failed to pull the tool
