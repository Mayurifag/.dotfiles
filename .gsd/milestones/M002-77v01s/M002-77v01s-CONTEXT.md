# M002-77v01s: Cross-Platform Claude Code via Mise

**Gathered:** 2026-03-15
**Status:** Queued — pending auto-mode execution

## Project Description

Integrate `claude-code` into the chezmoi-managed mise global config so that `chezmoi apply` sets up Claude Code automatically on both Linux and Windows without any out-of-band install step.

## Why This Milestone

Claude Code is currently installed via a custom self-managed mechanism (`~/.local/share/claude/versions/`, `~/.local/bin/claude` symlink) that chezmoi doesn't know about. On Windows it has to be installed manually with no documented path. Since mise already manages all other dev tools in this repo and supports `claude-code` natively (via aqua backend on Linux/macOS, npm fallback on Windows), the correct single source of truth is `dot_config/mise/config.toml`. Adding it here means a fresh `chezmoi apply` + `mise install` gives a working `claude` binary on any platform with zero extra steps.

## User-Visible Outcome

### When this milestone is complete, the user can:

- Run `chezmoi apply && mise install` on a fresh Linux machine and get `claude` in PATH without any manual step
- Run `chezmoi apply && mise install` on a fresh Windows machine (Git Bash or PowerShell) and get `claude` in PATH without any manual step
- Remove the old custom `~/.local/share/claude/` directory without losing the `claude` command (it now lives under `~/.local/share/mise/installs/claude-code/`)

### Entry point / environment

- Entry point: `chezmoi apply` → `mise install` → `claude`
- Environment: local dev, Linux (primary) and Windows (secondary)
- Live dependencies involved: GCS binary distribution, npm registry (Windows fallback)

## Completion Class

- Contract complete means: `claude-code = "latest"` present in chezmoi-managed mise config; `chezmoi apply` produces a correct `~/.config/mise/config.toml`
- Integration complete means: `mise install` succeeds and `claude --version` works on Linux; on Windows the npm fallback installs and `claude --version` works
- Operational complete means: old custom install removed; no stale `~/.local/bin/claude` symlink conflicts with mise shim

## Final Integrated Acceptance

To call this milestone complete, we must prove:

- On Linux: `mise install` pulls the native binary and `claude --version` outputs a version
- Old custom install cleaned up: `~/.local/share/claude/versions/` and `~/.local/bin/claude` symlink gone or superseded
- `chezmoi apply --dry-run` produces no errors related to the mise config change

## Risks and Unknowns

- **Symlink conflict** — `~/.local/bin/claude` points to the old custom install; if mise puts its shim in the same path a conflict may exist. Need to verify mise shim location and remove old symlink cleanly. A `run_once` chezmoi script is the right vehicle.
- **Windows fallback is npm, not native binary** — `npm:@anthropic-ai/claude-code` installs a JS wrapper (`cli.js`) rather than a bare native ELF. It works correctly but is heavier. Anthropic's aqua registry explicitly excludes Windows (`supported_envs: [darwin, linux]`). This is acceptable — the official Windows distribution path is npm.
- **`latest` version pinning** — Using `latest` means `mise install` always gets the newest version; no lockfile. Acceptable for a personal dotfiles use case.

## Existing Codebase / Prior Art

- `dot_config/mise/config.toml` — global mise config, plain TOML (no chezmoi template); `claude-code = "latest"` goes here
- `~/.local/share/claude/versions/2.1.76` — current custom binary install (unmanaged by chezmoi); to be removed
- `~/.local/bin/claude` — symlink to above; conflicts with mise shim path; chezmoi `run_once` script should remove it before `mise install`
- `windows/INSTRUCTION.md` — Windows setup manual; has open TODO about claude install; update to reflect mise handles it
- `install/Wingetfile` — winget packages; mise is already listed here; no change needed

> See `.gsd/DECISIONS.md` for all architectural and pattern decisions — it is an append-only register; read it during planning, append to it during execution.

## Relevant Requirements

- No existing REQUIREMENTS.md — new capability, no existing requirement contract to advance.

## Scope

### In Scope

- Add `claude-code = "latest"` to `dot_config/mise/config.toml`
- Add a chezmoi `run_once` script to remove `~/.local/bin/claude` symlink and `~/.local/share/claude/` directory on Linux
- Update `windows/INSTRUCTION.md` to remove/replace the manual claude install TODO
- Verify `mise install` resolves correctly on Linux (native binary via aqua backend)

### Out of Scope / Non-Goals

- Auditing other mise config tools for Windows compatibility — separate concern
- Configuring Claude Code settings (already handled by `dot_claude/settings.json`)
- Native Windows binary via custom http backend — acceptable complexity tradeoff; npm fallback works
- Managing claude version pinning or upgrade automation — `latest` is sufficient

## Technical Constraints

- `dot_config/mise/config.toml` is currently plain TOML (no chezmoi template); if no OS-conditional logic is needed, it stays plain — same `claude-code = "latest"` entry works on both platforms
- If OS-conditional is ever needed, rename to `config.toml.tmpl` and add `chezmoi:template` header
- chezmoi `run_once` scripts run exactly once per machine; script name hash determines identity — choose a descriptive stable name

## Integration Points

- `mise` — manages tool installs; claude-code entry in global config is all that's needed
- `chezmoi` — manages `dot_config/mise/config.toml`; `run_once` script lives in chezmoi source root or `dot_local/bin/` equivalent

## Open Questions

- None — scope is settled.
