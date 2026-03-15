---
id: T01
parent: S02
milestone: M008-9m50ua
provides:
  - .chezmoiignore expanded with 10 Linux/macOS-only path exclusions for Windows
  - windows/INSTRUCTION.md WT TODO block removed
key_files:
  - .chezmoiignore
  - windows/INSTRUCTION.md
key_decisions:
  - "Used eq windows block (not ne linux) for exclusions — macOS should still get btop, mpv, ghostty, zsh configs"
duration: 5m
verification_result: pass
completed_at: 2026-03-15
---

# T01: Expand .chezmoiignore Windows exclusions + update INSTRUCTION.md

**10 Linux/macOS-only config paths gated from deploying on Windows via `.chezmoiignore`; WT configuration TODO removed from INSTRUCTION.md.**

## What Happened

Added 10 target paths to the existing `{{ if eq .chezmoi.os "windows" }}` block in `.chezmoiignore`: `.config/btop/`, `.config/yakuakerc`, `.config/konsolerc`, `.config/ghostty/`, `.config/waystt/`, `.config/mpv/`, `.config/espanso/`, `.zshrc`, `zsh/`, `.local/bin/`. These join the existing `run_after_cz_apply.sh` entry in the same block.

Used `eq windows` (exclude on Windows) rather than `ne linux` (exclude on non-Linux) because some of these configs are valid on macOS too (btop, mpv, ghostty, zsh).

Removed the WT TODO block from `windows/INSTRUCTION.md` — 6 lines covering font, quake, Dracula, default profile, and focus mode. These are now automated by S01's settings.json.

## Deviations

None.

## Files Created/Modified

- `.chezmoiignore` — added 10 exclusion lines to `eq windows` block
- `windows/INSTRUCTION.md` — removed WT configuration TODO block (6 lines)
