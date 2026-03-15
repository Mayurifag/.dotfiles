---
id: S01
milestone: M007
provides:
  - init.ps1 extended to 14 steps (was 9) — full bootstrap from winget apps through language packages
  - mise config bootstrap via raw GitHub download with template directive stripping
  - Direct package install commands (npm/cargo/go/gem/uv) avoiding make dependency
  - preflight.ps1 — downloadable readiness check with 6 checks and chezmoi init
  - INSTRUCTION.md rewritten for the two-script automated flow
  - GnuWin32.Make added to Wingetfile
key_decisions:
  - "D024: Direct package installs instead of make — repo not available during bootstrap"
  - "Strip {{ lines from config.toml.tmpl — simple, correct, excludes Linux-only tools on Windows"
  - "Admin warning (not block) in preflight — works elevated, just unnecessary"
patterns_established:
  - Raw GitHub download for pre-chezmoi bootstrap files with template directive stripping
  - Colored pass/fail readiness check pattern with failure accumulator
  - Two-script bootstrap pipeline: init.ps1 (admin, installs everything) → preflight.ps1 (user, verifies and inits chezmoi)
drill_down_paths:
  - .gsd/milestones/M007/slices/S01/tasks/T01-SUMMARY.md
  - .gsd/milestones/M007/slices/S01/tasks/T02-SUMMARY.md
  - .gsd/milestones/M007/slices/S01/tasks/T03-SUMMARY.md
duration: ~35m
verification_result: pass
completed_at: 2026-03-15
---

# S01: Complete init.ps1 + preflight.ps1 + INSTRUCTION.md

**Windows bootstrap pipeline completed: init.ps1 installs all tooling (14 steps), preflight.ps1 verifies readiness and runs chezmoi init, INSTRUCTION.md documents the flow.**

## What Happened

Three tasks delivered the full two-script bootstrap pipeline:

**T01** extended init.ps1 from 9 to 14 steps. Steps 10-14 add: PATH wiring for GnuWin32 Make, Git utils, and mise shims; mise config bootstrap by downloading `config.toml.tmpl` from raw GitHub and stripping chezmoi template directives (`{{` lines); `mise install --yes` to install all runtimes; direct language package installation by downloading individual install files and running npm/cargo/go/gem/uv commands; and a post-install instruction block for SSH key (KeePassXC), ejson key symlink, and the preflight.ps1 download command.

**T02** created preflight.ps1 with 6 readiness checks (git, bash, chezmoi, ejson, ejson keys, SSH key), each printing colored PASS/FAIL output. Failures accumulate and print actionable fix hints. When all pass, the user confirms and `chezmoi init git@github.com:Mayurifag/.dotfiles.git --ssh` runs.

**T03** rewrote INSTRUCTION.md to reflect the automated flow: system prep → init.ps1 → manual SSH/ejson → preflight.ps1 → chezmoi diff/apply. Removed stale TODOs (PowerShell profile, shared aliases — both handled by M001). Removed old standalone ejson and chezmoi sections.

## Cross-Slice Verification

All verification checks from S01-PLAN.md passed:

| Check | Result |
|-------|--------|
| GnuWin32.Make in Wingetfile | ✓ |
| init.ps1 PS syntax valid | ✓ VALID |
| preflight.ps1 PS syntax valid | ✓ VALID |
| init.ps1 references mise install | ✓ |
| init.ps1 references preflight | ✓ |
| preflight.ps1 checks ssh-add | ✓ |
| preflight.ps1 checks ejson | ✓ |
| preflight.ps1 has chezmoi init command | ✓ |
| INSTRUCTION.md references init.ps1 | ✓ |
| INSTRUCTION.md references preflight | ✓ |
| No stale "Powershell profile" TODO | ✓ (0 matches) |
| No stale "Shared aliases" TODO | ✓ (0 matches) |

## Files Created/Modified

- `install/Wingetfile` — added `GnuWin32.Make`
- `windows/init.ps1` — extended from 9 to 14 steps
- `windows/preflight.ps1` — new (141 lines)
- `windows/INSTRUCTION.md` — rewritten for two-script flow
