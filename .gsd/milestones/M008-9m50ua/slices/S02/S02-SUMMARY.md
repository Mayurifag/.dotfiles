---
id: S02
milestone: M008-9m50ua
provides:
  - .chezmoiignore expanded with 10 Linux/macOS-only path exclusions for Windows
  - windows/INSTRUCTION.md WT TODO block removed
key_decisions:
  - Used eq windows block (not ne linux) — macOS should still get btop, mpv, ghostty, zsh configs
observability_surfaces:
  - "grep -c 'btop\|yakuakerc\|ghostty\|waystt\|mpv\|espanso\|zshrc' .chezmoiignore"
drill_down_paths:
  - .gsd/milestones/M008-9m50ua/slices/S02/tasks/T01-SUMMARY.md
duration: ~5m
verification_result: pass
completed_at: 2026-03-15
---

# S02: chezmoiignore Cleanup + Docs

**10 Linux/macOS-only config paths excluded from Windows deployment via `.chezmoiignore`; Windows Terminal configuration TODO removed from INSTRUCTION.md.**

## What Happened

Single-task slice. Added `.config/btop/`, `.config/yakuakerc`, `.config/konsolerc`, `.config/ghostty/`, `.config/waystt/`, `.config/mpv/`, `.config/espanso/`, `.zshrc`, `zsh/`, `.local/bin/` to the `{{ if eq .chezmoi.os "windows" }}` block in `.chezmoiignore`. Removed the 6-line WT TODO block from `windows/INSTRUCTION.md`.

## Files Created/Modified

- `.chezmoiignore` — 10 new exclusion lines in `eq windows` block
- `windows/INSTRUCTION.md` — WT TODO block removed
