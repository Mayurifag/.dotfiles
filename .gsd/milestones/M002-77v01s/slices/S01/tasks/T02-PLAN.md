---
estimated_steps: 5
estimated_files: 1
---

# T02: Write run_once cleanup script

**Slice:** S01 — Mise-managed claude-code with cleanup
**Milestone:** M002-77v01s

## Description

Create a chezmoi `run_once` script that removes the old custom claude install (`~/.local/bin/claude` symlink and `~/.local/share/claude/` directory) on Linux. The script must run before the user runs `mise install` so there is no symlink conflict. chezmoi run_once scripts execute during `chezmoi apply` — name determines identity (name hash = run-once key). The script should be Linux-only (guard with `uname` or use `.chezmoiignore` to exclude on Windows).

## Steps

1. Create `run_once_remove-old-claude-install.sh` in the chezmoi source root
2. Script header: `#!/usr/bin/env bash` + `set -euo pipefail`
3. Add OS guard: exit early if not Linux (`uname -s` != `Linux`) so the script is safe even if chezmoi applies it on macOS or via cross-platform testing
4. Remove symlink: `rm -f "$HOME/.local/bin/claude"`
5. Remove directory: `rm -rf "$HOME/.local/share/claude"`
6. Make script executable: `chmod +x run_once_remove-old-claude-install.sh`
7. Confirm chezmoi tracks it: `chezmoi managed | grep run_once`

## Must-Haves

- [ ] Script is executable (`chmod +x`)
- [ ] Script has OS guard — exits cleanly if not Linux
- [ ] Removes `~/.local/bin/claude` symlink with `rm -f` (safe if absent)
- [ ] Removes `~/.local/share/claude/` with `rm -rf` (safe if absent)
- [ ] `chezmoi managed` shows the script is tracked

## Verification

- `head -5 run_once_remove-old-claude-install.sh` shows shebang and set flags
- `chezmoi managed 2>/dev/null | grep run_once` returns the script name
- `chezmoi apply --dry-run 2>&1 | grep -i error` returns empty

## Observability Impact

chezmoi tracks run_once scripts by a hash of their name; once executed the hash is recorded in `~/.local/share/chezmoi/.chezmoistate.boltdb`. Signals a future agent can use:

- **Script present:** `ls -la ~/.local/share/chezmoi/run_once_remove-old-claude-install.sh` — confirms file is in the source state
- **Tracked by chezmoi:** `chezmoi managed 2>/dev/null | grep run_once` — confirms chezmoi sees the script
- **Already ran:** chezmoi won't re-run a run_once script whose name-hash is already in the state DB; to force re-run: `chezmoi state delete-bucket --bucket=scriptState`
- **Failure state:** if the script exits non-zero during `chezmoi apply`, apply aborts and prints the script name + exit code to stderr — visible in `chezmoi apply 2>&1`
- **Post-apply confirmation:** `[ -L ~/.local/bin/claude ] && echo SYMLINK_STILL_EXISTS || echo SYMLINK_GONE` and `[ -d ~/.local/share/claude ] && echo DIR_STILL_EXISTS || echo DIR_GONE`

## Inputs

- Knowledge that `~/.local/bin/claude` is a symlink and `~/.local/share/claude/` is the old install dir

## Expected Output

- `run_once_remove-old-claude-install.sh` — executable chezmoi run_once script removing old claude install
