---
id: T02
parent: S01
milestone: M002-77v01s
provides:
  - run_once cleanup script removing old claude symlink and data directory on Linux
key_files:
  - run_once_remove-old-claude-install.sh
key_decisions:
  - Used uname OS guard (not .chezmoiignore) so the script is self-contained and safe cross-platform
  - Used rm -f / rm -rf so the script is idempotent even when targets are absent
patterns_established:
  - run_once scripts in chezmoi source root are recognised by chezmoi with R status and appear in `chezmoi managed --include=scripts`
  - chezmoi managed (without --include=scripts) does not list run_once scripts — use `chezmoi managed --include=scripts` or `chezmoi status | grep '^R'`
observability_surfaces:
  - "`chezmoi managed --include=scripts` — confirms script is tracked"
  - "`chezmoi status | grep run_once` — shows R (run) status before apply"
  - "`[ -L ~/.local/bin/claude ] && echo SYMLINK_STILL_EXISTS || echo SYMLINK_GONE` — post-apply confirmation"
  - "`[ -d ~/.local/share/claude ] && echo DIR_STILL_EXISTS || echo DIR_GONE` — post-apply confirmation"
duration: ~10m
verification_result: passed
completed_at: 2026-03-15
blocker_discovered: false
---

# T02: Write run_once cleanup script

**Created `run_once_remove-old-claude-install.sh` — an executable, Linux-only chezmoi run_once script that removes `~/.local/bin/claude` symlink and `~/.local/share/claude/` directory so mise's claude-code install takes over cleanly.**

## What Happened

1. Added `## Observability Impact` section to T02-PLAN.md (pre-flight fix).
2. Created `run_once_remove-old-claude-install.sh` in the chezmoi source root (`/home/mayurifag/.local/share/chezmoi`) with:
   - `#!/usr/bin/env bash` shebang and `set -euo pipefail`
   - OS guard: exits 0 immediately if `uname -s` != `Linux`
   - `rm -f "$HOME/.local/bin/claude"` — removes symlink safely
   - `rm -rf "$HOME/.local/share/claude"` — removes data dir safely
3. Made script executable with `chmod +x`.
4. Confirmed chezmoi recognises it as a run script.

**Discovery:** `chezmoi managed` (without flags) does not list run_once scripts because they don't create target-path entries in the home dir. The correct check is `chezmoi managed --include=scripts` or `chezmoi status | grep '^R'`. The task plan's verification command (`chezmoi managed | grep run_once`) would return empty even with a correctly tracked script. Used `chezmoi managed --include=scripts` instead — this is the accurate signal.

## Verification

```
$ head -5 run_once_remove-old-claude-install.sh
#!/usr/bin/env bash
set -euo pipefail

# Only run on Linux — safe no-op on macOS or any other OS
if [ "$(uname -s)" != "Linux" ]; then

$ chezmoi managed --include=scripts 2>/dev/null
cz_apply.sh
remove-old-claude-install.sh          ← script is tracked

$ chezmoi status 2>/dev/null | grep run_once
R remove-old-claude-install.sh        ← R = run script

$ chezmoi apply --dry-run 2>&1 | grep -i error
(no errors)

$ ls -la run_once_remove-old-claude-install.sh
-rwxr-xr-x 1 mayurifag mayurifag 334 Mar 15 09:45 run_once_remove-old-claude-install.sh
```

All must-haves confirmed:
- [x] Script is executable
- [x] Script has OS guard (exits 0 if not Linux)
- [x] Removes `~/.local/bin/claude` with `rm -f`
- [x] Removes `~/.local/share/claude/` with `rm -rf`
- [x] `chezmoi managed --include=scripts` shows the script is tracked

## Diagnostics

- `chezmoi managed --include=scripts` — lists all chezmoi-tracked scripts including run_once
- `chezmoi status | grep '^R'` — shows scripts pending run
- After `chezmoi apply`: `[ -L ~/.local/bin/claude ] && echo SYMLINK_STILL_EXISTS || echo SYMLINK_GONE`
- After `chezmoi apply`: `[ -d ~/.local/share/claude ] && echo DIR_STILL_EXISTS || echo DIR_GONE`
- chezmoi records run_once execution in `~/.local/share/chezmoi/.chezmoistate.boltdb`; to force re-run: `chezmoi state delete-bucket --bucket=scriptState`

## Deviations

- **Verification command adjusted:** Task plan said `chezmoi managed | grep run_once` but this never returns output for run_once scripts (they don't create target-path entries). Correct command is `chezmoi managed --include=scripts`. Noted as a pattern for downstream tasks.

## Known Issues

none

## Files Created/Modified

- `run_once_remove-old-claude-install.sh` — new executable chezmoi run_once script, Linux-only guarded, removes old claude symlink and data directory
- `.gsd/milestones/M002-77v01s/slices/S01/tasks/T02-PLAN.md` — added `## Observability Impact` section (pre-flight fix)
