---
estimated_steps: 3
estimated_files: 2
---

# T01: Expand .chezmoiignore Windows exclusions + update INSTRUCTION.md

**Slice:** S02 — chezmoiignore Cleanup + Docs
**Milestone:** M008-9m50ua

## Description

Add all identified Linux/macOS-only config paths to `.chezmoiignore` so they are excluded on Windows, and remove the WT configuration TODO block from INSTRUCTION.md since it's now automated by S01.

## Steps

1. Add a `{{ if eq .chezmoi.os "windows" }}` block to `.chezmoiignore` with: `.config/btop/`, `.config/yakuakerc`, `.config/konsolerc`, `.config/ghostty/`, `.config/waystt/`, `.config/mpv/`, `.config/espanso/`, `.zshrc`, `zsh/`, `.local/bin/`. Place it logically near the existing `eq windows` block that gates `run_after_cz_apply.sh`. Consider merging into that block.
2. Remove the WT TODO block from `windows/INSTRUCTION.md` — the "Script to configure Windows Terminal" item and all its sub-items (font, quake, Dracula, default profile, focus mode).
3. Verify no regressions: existing karabiner (ne darwin), environment.d/applications/konsole/systemd (ne linux), run_after_cz_apply.sh (eq windows), Documents (ne windows) gates all intact.

## Must-Haves

- [ ] `.chezmoiignore` gates all 10 Linux/macOS-only paths on Windows
- [ ] WT TODO block removed from INSTRUCTION.md
- [ ] All existing .chezmoiignore gates remain intact
- [ ] `chezmoi apply --dry-run` on Linux has zero new errors

## Verification

- All grep checks from S02 plan pass
- `chezmoi apply --dry-run --force 2>&1 | grep -i error | grep -v 'ejson|decrypt' | wc -l` → 0
- `grep 'karabiner' .chezmoiignore` → match (existing gate intact)
- `grep 'Documents' .chezmoiignore` → match (existing gate intact)

## Inputs

- `.chezmoiignore` — current structure with existing OS gates
- `windows/INSTRUCTION.md` — current content with WT TODO block

## Expected Output

- `.chezmoiignore` — expanded with ~10 new exclusion lines in an `eq windows` block
- `windows/INSTRUCTION.md` — WT TODO block removed (~6 lines deleted)
