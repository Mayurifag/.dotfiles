---
id: T01
parent: S01
milestone: M002-77v01s
provides:
  - claude-code entry in mise global config
key_files:
  - dot_config/mise/config.toml
key_decisions:
  - No template needed; claude-code = "latest" works identically on Linux and Windows via mise's backend selection
patterns_established:
  - Tools added in alphabetical order within the [tools] section
observability_surfaces:
  - "grep 'claude-code' dot_config/mise/config.toml"
  - "chezmoi apply --dry-run 2>&1 | grep -i error"
  - "claude --version (post mise install)"
duration: 5m
verification_result: passed
completed_at: 2026-03-15
blocker_discovered: false
---

# T01: Add claude-code to mise config

**Added `claude-code = "latest"` to the `[tools]` section of `dot_config/mise/config.toml` in alphabetical order after `chezmoi`.**

## What Happened

Opened `dot_config/mise/config.toml`, inserted `claude-code = "latest"` on the line immediately after `chezmoi = "latest"` (alphabetical order preserved). Also applied two pre-flight fixes: added inline task descriptions to all four task entries in `S01-PLAN.md`, and added an `## Observability Impact` section to `T01-PLAN.md`.

## Verification

- `grep 'claude-code' dot_config/mise/config.toml` → `claude-code = "latest"` ✓
- `cat dot_config/mise/config.toml` confirms entry sits inside `[tools]` block after `chezmoi = "latest"` ✓
- `chezmoi apply --dry-run 2>&1 | grep -i error` → empty (no errors) ✓

Slice-level checks applicable at this stage:
- `grep 'claude-code' dot_config/mise/config.toml` ✓ passes
- `chezmoi apply --dry-run 2>&1 | grep -i error` ✓ passes
- Remaining checks (run_once script tracking, symlink/dir gone, mise install, claude --version) require T02–T04.

## Diagnostics

To inspect after the fact:
- `grep 'claude-code' dot_config/mise/config.toml` — confirms entry exists
- `chezmoi apply --dry-run` — confirms TOML is valid and chezmoi accepts the file
- After full apply + `mise install`: `which claude` and `claude --version` are the live success signals

## Deviations

None. Task executed exactly as planned.

## Known Issues

None.

## Files Created/Modified

- `dot_config/mise/config.toml` — added `claude-code = "latest"` in `[tools]` after `chezmoi = "latest"`
- `.gsd/milestones/M002-77v01s/slices/S01/S01-PLAN.md` — added inline descriptions to all four task entries (pre-flight fix)
- `.gsd/milestones/M002-77v01s/slices/S01/tasks/T01-PLAN.md` — added `## Observability Impact` section (pre-flight fix)
