---
id: T03
parent: S01
milestone: M007
provides:
  - Rewritten INSTRUCTION.md reflecting two-script bootstrap flow
  - Stale TODOs removed (Powershell profile, Shared aliases)
  - ejson key symlink instruction with correct path
  - SSH key setup instruction referencing KeePassXC
key_files:
  - windows/INSTRUCTION.md
key_decisions:
  - "Removed old standalone ejson/chezmoi sections — now covered by init.ps1 output + preflight.ps1"
duration: 5m
verification_result: pass
completed_at: 2026-03-15
---

# T03: Update INSTRUCTION.md

**INSTRUCTION.md rewritten for the init.ps1 → manual SSH/ejson → preflight.ps1 flow; stale TODOs for PowerShell profile and shared aliases removed.**

## What Happened

Restructured INSTRUCTION.md into clear sequential sections: system preparation (with init.ps1 command), manual setup (SSH via KeePassXC, ejson key symlink to `D:\OpenCloud\...`), preflight & chezmoi init (new terminal emphasis), after chezmoi init (diff/apply/mise install), other setup, and remaining valid TODOs. Removed "Powershell profile" and "Shared aliases" TODOs (handled by M001). Removed old ejson and chezmoi manual sections (replaced by automated flow).

## Deviations

None.

## Files Created/Modified

- `windows/INSTRUCTION.md` — rewritten
