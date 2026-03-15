---
estimated_steps: 5
estimated_files: 0
---

# T04: Apply and verify on Linux

**Slice:** S01 — Mise-managed claude-code with cleanup
**Milestone:** M002-77v01s

## Description

Run `chezmoi apply` on the current Linux machine to deploy all three changes (mise config entry, run_once script, doc update), then verify the run_once script fired correctly and `mise install` + `claude --version` succeed.

## Steps

1. Run `chezmoi apply --dry-run` and confirm no errors
2. Run `chezmoi apply` (the run_once script will execute here, removing the old install)
3. Verify `~/.local/bin/claude` symlink is absent
4. Verify `~/.local/share/claude/` directory is absent
5. Run `mise install` and confirm claude-code is downloaded
6. Run `claude --version` and confirm it outputs a version from the mise-managed binary

## Must-Haves

- [ ] `chezmoi apply --dry-run` exits 0 with no errors
- [ ] `~/.local/bin/claude` symlink absent after apply
- [ ] `~/.local/share/claude/` directory absent after apply
- [ ] `mise install` succeeds (claude-code pulled via aqua backend)
- [ ] `claude --version` outputs a version string

## Verification

- `chezmoi apply --dry-run 2>&1 | grep -i error` → empty
- `[ -L ~/.local/bin/claude ] && echo SYMLINK_EXISTS || echo SYMLINK_GONE` → `SYMLINK_GONE`
- `[ -d ~/.local/share/claude ] && echo DIR_EXISTS || echo DIR_GONE` → `DIR_GONE`
- `mise install 2>&1 | tail -5` → success output
- `claude --version` → version string (e.g. `1.x.x`)
- `which claude` → path under `~/.local/share/mise/` not `~/.local/bin/`

## Inputs

- All prior tasks completed: T01 (config updated), T02 (run_once script present), T03 (doc updated)

## Expected Output

- Live system with mise-managed claude-code; old install cleaned up; `claude --version` works
