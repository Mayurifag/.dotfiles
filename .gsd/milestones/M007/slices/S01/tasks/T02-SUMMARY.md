---
id: T02
parent: S01
milestone: M007
provides:
  - windows/preflight.ps1 — downloadable readiness check script
  - 6 prerequisite checks (git, bash, chezmoi, ejson, ejson keys, SSH key)
  - User confirmation before chezmoi init
  - Post-init guidance (chezmoi diff, chezmoi apply)
key_files:
  - windows/preflight.ps1
key_decisions:
  - "Admin warning (not block) — preflight works fine elevated, just unnecessary"
  - "Fallback check for mise shims path when chezmoi not on PATH directly"
patterns_established:
  - Colored pass/fail check pattern with failure accumulator array
duration: 10m
verification_result: pass
completed_at: 2026-03-15
---

# T02: Create preflight.ps1

**preflight.ps1 runs 6 readiness checks with colored output, blocks with actionable fix hints on failure, and runs `chezmoi init git@github.com:Mayurifag/.dotfiles.git --ssh` after user confirmation.**

## What Happened

Created `windows/preflight.ps1` with admin-elevation warning (non-blocking), 6 sequential checks each printing PASS/FAIL with color, a failure accumulator that prints all missing items at once, and a confirmation prompt before running chezmoi init. Post-init, it prints `chezmoi diff` and `chezmoi apply` as next steps.

## Deviations

None.

## Files Created/Modified

- `windows/preflight.ps1` — new file (141 lines)
