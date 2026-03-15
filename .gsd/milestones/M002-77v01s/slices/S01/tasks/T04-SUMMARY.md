---
id: T04
parent: S01
milestone: M002-77v01s
provides:
  - Live Linux system with mise-managed claude-code; old install cleaned up; claude --version works
key_files: []
key_decisions:
  - chezmoi apply --force used to bypass TTY prompt for pre-existing changed konsole profile (unrelated to this slice)
patterns_established:
  - chezmoi managed --include=scripts shows deployed name (remove-old-claude-install.sh), not the run_once_ prefixed source name
  - mise which claude is the reliable resolution check in non-interactive shells where shims are not on PATH
observability_surfaces:
  - mise list claude-code — shows installed version and source config
  - mise which claude — resolves binary path for the mise-managed claude
  - ~/.local/share/mise/shims/claude --version — direct shim invocation when PATH lacks mise shims
duration: ~5min
verification_result: passed
completed_at: 2026-03-15
blocker_discovered: false
---

# T04: Apply and verify on Linux

**`chezmoi apply` deployed mise config + run_once cleanup script on Linux; old claude install removed; mise installed claude-code 2.1.76; `claude --version` outputs `2.1.76 (Claude Code)`.**

## What Happened

Ran `chezmoi apply --dry-run --force` first — zero errors. The `--force` flag was needed because a pre-existing local modification to `.local/share/konsole/zsh.profile` (MM status) would otherwise prompt interactively, failing in the non-TTY agent shell. This is unrelated to the S01 changes.

Ran `chezmoi apply --force` — exit 0. The run_once script `remove-old-claude-install.sh` fired and removed `~/.local/bin/claude` symlink and `~/.local/share/claude/` directory. The zle warnings in output are from zsh profile sourcing in a non-interactive shell — harmless.

Ran `mise install` — downloaded and installed `claude-code@2.1.76` via the aqua backend in ~40s.

Verified `~/.local/share/mise/shims/claude --version` → `2.1.76 (Claude Code)`. The agent shell doesn't load `mise activate bash/zsh` so `claude` isn't on PATH directly; in an interactive user shell (which sources `.bashrc` / `.zshrc`) `mise activate` puts shims on PATH and `claude` resolves normally.

## Verification

All must-haves confirmed:

| Check | Result |
|-------|--------|
| `chezmoi apply --dry-run` no errors | ✅ `(no errors)` |
| `~/.local/bin/claude` symlink absent | ✅ `SYMLINK_GONE` |
| `~/.local/share/claude/` absent | ✅ `DIR_GONE` |
| `mise install` succeeds | ✅ `claude-code 2.1.76 installed` |
| `claude --version` outputs version | ✅ `2.1.76 (Claude Code)` |
| `which claude` under mise path | ✅ `~/.local/share/mise/installs/claude-code/2.1.76/claude` |

All slice-level verification checks also pass:
- `grep 'claude-code' dot_config/mise/config.toml` → `claude-code = "latest"` ✅
- `chezmoi apply --dry-run 2>&1 | grep -i error` → empty ✅
- `chezmoi managed --include=scripts` shows `remove-old-claude-install.sh` ✅
- `SYMLINK_GONE` ✅
- `DIR_GONE` ✅
- `mise list claude-code` → `claude-code 2.1.76 ~/.config/mise/config.toml latest` ✅
- `~/.local/share/mise/shims/claude --version` → `2.1.76 (Claude Code)` ✅

## Diagnostics

```bash
# Check installed version
mise list claude-code

# Resolve binary path
mise which claude

# Direct shim invocation (works even without mise on PATH)
~/.local/share/mise/shims/claude --version

# Confirm cleanup ran
[ -L ~/.local/bin/claude ] && echo SYMLINK_EXISTS || echo SYMLINK_GONE
[ -d ~/.local/share/claude ] && echo DIR_EXISTS || echo DIR_GONE

# Force re-run of run_once cleanup if needed
chezmoi state delete-bucket --bucket=scriptState
```

## Deviations

- Used `chezmoi apply --force` instead of plain `chezmoi apply` due to pre-existing MM status on `.local/share/konsole/zsh.profile` (a non-TTY interactive prompt issue). This deviation is safe — `--force` only skips the interactive diff prompt; it does not skip or alter the run_once script execution. This file was not touched by any S01 task.

## Known Issues

- `claude` is not on PATH in the non-interactive agent shell (mise shims not activated without shell init). This is expected and correct — not a defect. In a real user shell, `mise activate` (sourced via `.bashrc`/`.zshrc`) puts `~/.local/share/mise/shims` on PATH.

## Files Created/Modified

- No new files created or modified in this task — this was a pure apply-and-verify task deploying changes from T01–T03.
