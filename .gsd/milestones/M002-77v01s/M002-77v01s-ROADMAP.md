# M002-77v01s: Cross-Platform Claude Code via Mise

**Vision:** `chezmoi apply && mise install` on a fresh machine (Linux or Windows) produces a working `claude` binary in PATH with no manual steps; the old custom install is cleanly removed.

## Success Criteria

- `grep 'claude-code' ~/.config/mise/config.toml` returns `claude-code = "latest"` after `chezmoi apply`
- `mise install` succeeds on Linux and downloads the claude-code binary via the aqua backend
- `claude --version` outputs a version string from a mise-managed binary (not the old `~/.local/bin/claude` symlink)
- `~/.local/bin/claude` symlink is absent after the run_once script executes
- `chezmoi apply --dry-run` produces no errors related to the mise config
- `windows/INSTRUCTION.md` no longer contains a manual claude install step — mise handles it

## Key Risks / Unknowns

- **Symlink conflict** — `~/.local/bin/claude` pointing to the old custom install could shadow the mise shim if not removed before `mise install`; the run_once script must fire before the user runs `mise install`

## Proof Strategy

- Symlink conflict → retired in S01 by shipping the run_once removal script (runs on `chezmoi apply`) and verifying via `chezmoi apply --dry-run` that the script is scheduled; actual removal verified by checking the symlink is absent post-apply on the current machine

## Verification Classes

- Contract verification: `chezmoi apply --dry-run` on Linux; `grep` confirming `claude-code = "latest"` in the deployed config; `chezmoi execute-template` on any modified templates
- Integration verification: `mise install` resolves claude-code on Linux and `claude --version` outputs a version
- Operational verification: run_once script executes on `chezmoi apply`; symlink/directory absent post-apply
- UAT / human verification: on Windows, `mise install` uses npm fallback and `claude --version` works (cannot verify on Linux)

## Milestone Definition of Done

This milestone is complete only when all are true:

- `dot_config/mise/config.toml` contains `claude-code = "latest"` and `chezmoi apply --dry-run` shows no errors
- The run_once cleanup script is present in the chezmoi source and executes on `chezmoi apply` on Linux
- `~/.local/bin/claude` symlink is absent and `~/.local/share/claude/` is removed on the current machine
- `mise install` succeeds and `claude --version` returns a version from the mise-managed binary
- `windows/INSTRUCTION.md` reflects that mise handles claude installation — manual TODO removed
- All three deliverables are shipped in S01

## Requirement Coverage

- Covers: No existing REQUIREMENTS.md — new capability milestone, no prior active requirements to map
- Orphan risks: none

## Slices

- [x] **S01: Mise-managed claude-code with cleanup** `risk:medium` `depends:[]`
  > After this: `chezmoi apply && mise install` on Linux delivers `claude --version` from a mise-managed binary; the old symlink and custom directory are gone; Windows is covered by the same config entry using the npm fallback

## Boundary Map

### S01 outputs

Produces:
- `dot_config/mise/config.toml` with `claude-code = "latest"` entry (chezmoi-managed, plain TOML — no template needed)
- `run_once_remove-old-claude-install.sh` chezmoi script (Linux-gated, removes `~/.local/bin/claude` and `~/.local/share/claude/`)
- `windows/INSTRUCTION.md` updated to remove/replace manual claude TODO

Consumes:
- nothing (no prior slice dependency)
