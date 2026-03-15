---
id: M007
provides:
  - Two-script Windows bootstrap pipeline (init.ps1 → preflight.ps1)
  - init.ps1 extended to 14 steps: winget apps + mise config bootstrap + mise runtimes + language packages + post-install instructions
  - preflight.ps1: 6 readiness checks (git, bash, chezmoi, ejson, ejson keys, SSH key) + chezmoi init
  - INSTRUCTION.md rewritten for automated two-script flow
  - GnuWin32.Make added to Wingetfile
key_decisions:
  - D023: Single slice — all deliverables tightly coupled
  - D024: Direct package installs instead of make during bootstrap — repo not available pre-chezmoi
patterns_established:
  - Raw GitHub download for pre-chezmoi bootstrap with template directive stripping
  - Two-script pipeline: admin init → manual SSH/ejson → user preflight → chezmoi init
observability_surfaces:
  - init.ps1 step-by-step progress output [1/14] through [14/14]
  - preflight.ps1 colored PASS/FAIL per check
  - Post-init guidance: chezmoi diff / chezmoi apply
requirement_outcomes: []
duration: ~35m
verification_result: pass
completed_at: 2026-03-15
---

# M007: Windows Bootstrap Flow (init → preflight → chezmoi)

**Fresh Windows install now follows a two-script pipeline: `init.ps1` (admin) installs all tooling through 14 automated steps, then `preflight.ps1` (user, new terminal) verifies readiness and runs `chezmoi init` — with only SSH key and ejson key symlink as manual steps in between.**

## What Happened

Single-slice milestone (S01) delivering four file changes:

**init.ps1** was extended from 9 to 14 steps. The new steps add: PATH wiring for GnuWin32 Make + Git POSIX utils + mise shims (step 10), mise config bootstrap by downloading `config.toml.tmpl` from raw GitHub and stripping chezmoi template directives (step 11), `mise install --yes` for all runtimes (step 12), direct language package installation via npm/cargo/go/gem/uv using install files downloaded from GitHub (step 13), and a post-install instruction block covering SSH key setup via KeePassXC, ejson key symlink, and the preflight.ps1 download command (step 14).

**preflight.ps1** was created as a downloadable script that runs 6 readiness checks (git, bash, chezmoi, ejson binary, ejson key directory, SSH key in agent) with colored PASS/FAIL output. Failures accumulate and print actionable fix hints. When all pass, the user confirms and `chezmoi init git@github.com:Mayurifag/.dotfiles.git --ssh` runs.

**INSTRUCTION.md** was rewritten to reflect the automated flow: system prep → init.ps1 → manual SSH/ejson setup → preflight.ps1. Stale TODOs removed (PowerShell profile, shared aliases — handled by M001). Old standalone ejson and chezmoi sections replaced by the automated flow.

**Wingetfile** received `GnuWin32.Make` for post-bootstrap `make` availability.

## Cross-Slice Verification

All success criteria from the roadmap verified:

| Criterion | Result |
|-----------|--------|
| init.ps1 installs GnuWin32.Make and runs mise packages | ✓ (steps 7, 12, 13) |
| init.ps1 prints SSH/ejson/preflight instructions | ✓ (step 14) |
| preflight.ps1 checks 6 prerequisites | ✓ |
| preflight.ps1 blocks on failure with fix hints | ✓ |
| preflight.ps1 runs chezmoi init after confirmation | ✓ |
| INSTRUCTION.md reflects two-script flow | ✓ |
| Both scripts pass PS syntax check | ✓ VALID |
| GnuWin32.Make in Wingetfile | ✓ |

## Forward Intelligence

### What the next milestone should know
- The two-script pipeline is: `init.ps1` (admin, fresh install) → manual SSH/ejson → `preflight.ps1` (user, new terminal) → `chezmoi init`
- init.ps1 creates a temporary mise config at `~/.config/mise/config.toml` by stripping chezmoi directives from the template. After `chezmoi apply`, chezmoi overwrites this with the proper rendered version. No conflict.
- `GnuWin32.Make` is in Wingetfile but `make` is not used during bootstrap — language packages are installed directly. `make mise-packages` is available post-chezmoi for future use.

### What's fragile
- The raw GitHub download URLs assume the `master` branch — if the default branch changes, these break.
- `GnuWin32.Make` via winget can silently fail — the script handles this gracefully (warns and continues) but make may not be available after init.ps1.
- The ejson key path (`D:\OpenCloud\...`) is hardcoded in the printed instructions — if the drive letter or path changes, the symlink command needs updating.

### Authoritative diagnostics
- `pwsh -NoProfile -Command "& { [System.Management.Automation.PSParser]::Tokenize((Get-Content 'windows/init.ps1' -Raw), [ref]$null) | Out-Null; 'VALID' }"` — PS syntax check for init.ps1
- `pwsh -NoProfile -Command "& { [System.Management.Automation.PSParser]::Tokenize((Get-Content 'windows/preflight.ps1' -Raw), [ref]$null) | Out-Null; 'VALID' }"` — PS syntax check for preflight.ps1

## Files Created/Modified

- `install/Wingetfile` — added `GnuWin32.Make`
- `windows/init.ps1` — extended from 9 to 14 steps
- `windows/preflight.ps1` — new (141 lines)
- `windows/INSTRUCTION.md` — rewritten for two-script flow
