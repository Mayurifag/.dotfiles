# S01: Mise-managed claude-code with cleanup

**Goal:** Ship `claude-code = "latest"` in the chezmoi-managed mise config, a run_once script that removes the old custom install, and an updated Windows instruction doc — so `chezmoi apply && mise install` delivers a working `claude` binary on Linux with no manual steps.

**Demo:** Running `chezmoi apply` on Linux: (1) deploys `~/.config/mise/config.toml` containing `claude-code = "latest"`, (2) fires the run_once removal script clearing `~/.local/bin/claude` and `~/.local/share/claude/`, then `mise install` pulls the native binary and `claude --version` outputs a version string.

## Must-Haves

- `claude-code = "latest"` present in `dot_config/mise/config.toml`
- `run_once_remove-old-claude-install.sh` present and correctly removes symlink + directory, Linux-only guarded
- `windows/INSTRUCTION.md` updated: manual claude TODO removed, note that mise handles it added
- `chezmoi apply --dry-run` shows no errors
- `mise install` + `claude --version` succeed on Linux

## Verification

- `grep 'claude-code' dot_config/mise/config.toml` returns `claude-code = "latest"`
- `chezmoi apply --dry-run 2>&1 | grep -i error` returns empty
- `chezmoi managed | grep run_once` shows the cleanup script is tracked
- `[ -L ~/.local/bin/claude ] && echo SYMLINK_STILL_EXISTS || echo SYMLINK_GONE` returns `SYMLINK_GONE` after apply
- `[ -d ~/.local/share/claude ] && echo DIR_STILL_EXISTS || echo DIR_GONE` returns `DIR_GONE` after apply
- `mise install 2>&1 | tail -5` and `claude --version` succeed

## Tasks

- [x] **T01: Add claude-code to mise config** `est:5m`
  - Why: mise needs the entry to pull the native claude binary on `mise install`
  - Files: `dot_config/mise/config.toml`
  - Do: Add `claude-code = "latest"` to `[tools]` section in alphabetical order after `chezmoi`
  - Verify: `grep 'claude-code' dot_config/mise/config.toml` returns `claude-code = "latest"`

- [x] **T02: Write run_once cleanup script** `est:15m`
  - Why: removes the old manual install (symlink + data dir) so mise's version takes over cleanly
  - Files: `run_once_remove-old-claude-install.sh` (new)
  - Do: Create Linux-only guarded script removing `~/.local/bin/claude` symlink and `~/.local/share/claude/` dir
  - Verify: `chezmoi managed | grep run_once` shows the script is tracked

- [x] **T03: Update windows/INSTRUCTION.md** `est:5m`
  - Why: Windows docs still reference a manual claude install TODO that mise now handles
  - Files: `windows/INSTRUCTION.md`
  - Do: Remove manual claude TODO, add note that mise handles it automatically
  - Verify: `grep -i 'claude' windows/INSTRUCTION.md` shows no old manual-install instruction

- [x] **T04: Apply and verify on Linux** `est:10m`
  - Why: end-to-end confirmation that `chezmoi apply && mise install && claude --version` works
  - Files: none (verification only)
  - Do: Run `chezmoi apply --dry-run`, then full apply, then `mise install`, then `claude --version`
  - Verify: all slice-level verification commands pass

## Files Likely Touched

- `dot_config/mise/config.toml`
- `run_once_remove-old-claude-install.sh` (new)
- `windows/INSTRUCTION.md`
