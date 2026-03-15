---
id: T03
parent: S01
milestone: M002-77v01s
provides:
  - windows/INSTRUCTION.md with manual claude install TODO removed
key_files:
  - windows/INSTRUCTION.md
key_decisions:
  - No replacement note added; the Chezmoi section already implies `mise install` runs after apply
patterns_established:
  - none
observability_surfaces:
  - none
duration: <5m
verification_result: passed
completed_at: 2026-03-15
blocker_discovered: false
---

# T03: Update windows/INSTRUCTION.md

**Removed the superseded manual claude install TODO from `windows/INSTRUCTION.md`; mise handles claude-code automatically.**

## What Happened

Opened `windows/INSTRUCTION.md`, located the TODO item:

> `- [ ] Even though PowerShell profile will have mise, install it also for bash in windows for claude`

Deleted that single line. The `mise install` step (already implied by the Chezmoi section) installs `claude-code = "latest"` automatically, making the manual instruction obsolete.

## Verification

```
grep -n 'claude' windows/INSTRUCTION.md
# → no output (exit 1) — confirmed line is gone and no other claude references exist
```

File remains valid Markdown; all other content is untouched.

## Diagnostics

- `grep -n 'claude' windows/INSTRUCTION.md` — should return no output after this change

## Deviations

none — optional positive note not added; existing Chezmoi section is sufficient

## Known Issues

none

## Files Created/Modified

- `windows/INSTRUCTION.md` — removed obsolete claude install TODO line
