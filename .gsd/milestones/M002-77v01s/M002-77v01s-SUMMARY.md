---
id: M002-77v01s
provides:
  - mise-managed claude-code entry in chezmoi config (dot_config/mise/config.toml)
  - run_once cleanup script removing old claude symlink and data directory on Linux
  - windows/INSTRUCTION.md with manual claude install TODO removed
key_decisions:
  - dot_config/mise/config.toml stays plain TOML (no .tmpl rename) — claude-code = "latest" works on Linux (aqua) and Windows (npm) via mise backend selection
  - Used run_once chezmoi script (not .chezmoiignore gating) to remove old install — fires during chezmoi apply, before mise install, eliminating symlink conflict window
  - No replacement note added in windows/INSTRUCTION.md — existing Chezmoi section already implies mise install handles it
patterns_established:
  - chezmoi managed --include=scripts is the correct command to verify run_once scripts are tracked (plain chezmoi managed never lists them — run_once scripts have no target-path entry in home dir)
  - chezmoi status | grep '^R' shows R status for scripts pending next apply
  - mise which claude is the reliable resolution check in non-interactive shells where mise shims are not on PATH
  - chezmoi apply --force needed in non-TTY shells when pre-existing MM-status files would trigger interactive diff prompt
observability_surfaces:
  - "grep 'claude-code' dot_config/mise/config.toml"
  - "chezmoi managed --include=scripts"
  - "mise list claude-code"
  - "mise which claude"
  - "~/.local/share/mise/shims/claude --version"
  - "[ -L ~/.local/bin/claude ] && echo SYMLINK_EXISTS || echo SYMLINK_GONE"
  - "[ -d ~/.local/share/claude ] && echo DIR_EXISTS || echo DIR_GONE"
requirement_outcomes: []
duration: ~35m
verification_result: passed
completed_at: 2026-03-15
---

# M002-77v01s: Cross-Platform Claude Code via Mise

**`chezmoi apply && mise install` on Linux delivers `claude --version` → `2.1.76 (Claude Code)` from a mise-managed binary via the aqua backend; the old `~/.local/bin/claude` symlink and `~/.local/share/claude/` directory are gone; Windows is covered by the same config entry via mise's npm fallback.**

## What Happened

This milestone was delivered in a single slice (S01) covering three coordinated changes that together eliminate the old ad-hoc claude install and replace it with a properly managed mise entry.

**Config entry (T01):** `claude-code = "latest"` was added to the `[tools]` section of `dot_config/mise/config.toml` in alphabetical order after `chezmoi`. The file stays plain TOML — no `.tmpl` rename required because mise's backend selection (aqua on Linux/macOS, npm on Windows) is transparent to the config entry. The same line works on both platforms.

**Cleanup script (T02):** `run_once_remove-old-claude-install.sh` was created in the chezmoi source root — an executable bash script with a `uname -s` Linux guard that removes `~/.local/bin/claude` with `rm -f` and `~/.local/share/claude/` with `rm -rf`. Both operations are idempotent (safe if targets are already absent). The run_once mechanism ensures this fires during `chezmoi apply` — before the user runs `mise install` — eliminating any symlink conflict window. A key discovery: `chezmoi managed` (without `--include=scripts`) never lists run_once scripts because they have no target-path entry in the home directory; the correct verification command is `chezmoi managed --include=scripts`.

**Windows docs (T03):** The single obsolete TODO line was removed from `windows/INSTRUCTION.md`:
> `- [ ] Even though PowerShell profile will have mise, install it also for bash in windows for claude`

No replacement note was needed — the existing Chezmoi section already implies `mise install` runs after apply, covering claude-code alongside all other tools.

**End-to-end verification (T04):** `chezmoi apply --force` deployed the config, fired the run_once script (clearing the old install), and `mise install` pulled `claude-code@2.1.76` via the aqua backend. `~/.local/share/mise/shims/claude --version` → `2.1.76 (Claude Code)`. The `--force` flag was required because a pre-existing MM-status konsole profile would have triggered an interactive diff prompt in the non-TTY agent shell — this is safe and unrelated to S01 changes.

## Cross-Slice Verification

All milestone success criteria verified on Linux:

| Success Criterion | Command | Result |
|-------------------|---------|--------|
| `claude-code = "latest"` in mise config after `chezmoi apply` | `grep 'claude-code' dot_config/mise/config.toml` | `claude-code = "latest"` ✅ |
| `mise install` succeeds and downloads claude-code via aqua backend | `mise list claude-code` | `2.1.76  ~/.config/mise/config.toml  latest` ✅ |
| `claude --version` outputs version from mise-managed binary | `~/.local/share/mise/shims/claude --version` | `2.1.76 (Claude Code)` ✅ |
| `~/.local/bin/claude` symlink is absent after run_once script | `[ -L ~/.local/bin/claude ] && echo EXISTS \|\| echo GONE` | `SYMLINK_GONE` ✅ |
| `chezmoi apply --dry-run` produces no errors | `chezmoi apply --dry-run --force 2>&1 \| grep -i error` | `(no errors)` ✅ |
| `windows/INSTRUCTION.md` no longer contains manual claude install step | `grep -i claude windows/INSTRUCTION.md` | `(no output)` ✅ |
| run_once script tracked by chezmoi | `chezmoi managed --include=scripts` | `remove-old-claude-install.sh` ✅ |
| Old data directory removed | `[ -d ~/.local/share/claude ] && echo EXISTS \|\| echo GONE` | `DIR_GONE` ✅ |

**Definition of done:** All three deliverables shipped in S01 ✅. All slice summaries exist ✅. No cross-slice integration points (single-slice milestone) ✅.

## Requirement Changes

- No existing REQUIREMENTS.md — this was a new capability milestone with no prior active requirement contracts. No requirement status transitions to record.

## Forward Intelligence

### What the next milestone should know
- `chezmoi apply --force` is safe in non-TTY environments and may be required when any tracked file has MM (modified) status from pre-existing local changes unrelated to the current change.
- mise shims are at `~/.local/share/mise/shims/` — use direct paths when testing in non-interactive shells where `mise activate` hasn't been sourced.
- The run_once script records execution state in `~/.local/share/chezmoi/.chezmoistate.boltdb`; to force re-run: `chezmoi state delete-bucket --bucket=scriptState`.
- `chezmoi managed --include=scripts` (not `chezmoi managed`) is the canonical way to verify run_once scripts are tracked.

### What's fragile
- The run_once script fires exactly once per machine (chezmoi hashes the script content). If the script needs to change, the filename must change or the state bucket must be manually cleared — otherwise chezmoi will not re-run it.
- `chezmoi managed --include=scripts` shows the deployed name (`remove-old-claude-install.sh`), not the source name (`run_once_remove-old-claude-install.sh`) — this asymmetry can be confusing.
- `claude` is not on PATH in non-interactive shells (mise shims require `mise activate` sourced via `.bashrc`/`.zshrc`). In a real user shell, `claude` resolves normally via `~/.local/share/mise/shims`.

### Authoritative diagnostics
- `mise list claude-code` — shows installed version and which config file sourced it; most reliable post-install signal.
- `chezmoi managed --include=scripts` — reliable script tracking check (never use `chezmoi managed` without flags for run_once scripts).
- `~/.local/share/mise/shims/claude --version` — version check that works in non-interactive shells without sourcing mise activate.

### What assumptions changed
- Assumed `chezmoi managed | grep run_once` would work — it doesn't. Scripts have no target-path entries in the home dir and require `--include=scripts` flag.
- Assumed plain `chezmoi apply` would work in agent shell — it doesn't when any tracked file has MM status; `--force` required in non-TTY environments.

## Files Created/Modified

- `dot_config/mise/config.toml` — added `claude-code = "latest"` in `[tools]` after `chezmoi = "latest"` (alphabetical order)
- `run_once_remove-old-claude-install.sh` — new executable chezmoi run_once script; Linux-only guarded via `uname -s`; removes old claude symlink and data directory
- `windows/INSTRUCTION.md` — removed obsolete manual claude install TODO line
