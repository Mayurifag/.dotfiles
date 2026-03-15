# S02: chezmoiignore Cleanup + Docs

**Goal:** Gate all Linux/macOS-only configs from deploying on Windows via `.chezmoiignore`, and update INSTRUCTION.md to remove the WT TODO block.
**Demo:** `chezmoi apply --dry-run` on Windows no longer lists btop, yakuakerc, konsolerc, ghostty, waystt, mpv, espanso, zsh, or .local/bin entries; INSTRUCTION.md has no WT configuration TODOs.

## Must-Haves

- `.chezmoiignore` excludes on Windows: `.config/btop/`, `.config/yakuakerc`, `.config/konsolerc`, `.config/ghostty/`, `.config/waystt/`, `.config/mpv/`, `.config/espanso/`, `.zshrc`, `zsh/`, `.local/bin/`
- `windows/INSTRUCTION.md` WT TODO block removed
- `chezmoi apply --dry-run` on Linux produces zero errors and zero regressions
- Existing `.chezmoiignore` gates (karabiner, environment.d, applications, konsole, systemd, Documents, run_after_cz_apply.sh) remain intact

## Verification

- `grep -c 'btop' .chezmoiignore` → ≥1
- `grep -c 'yakuakerc' .chezmoiignore` → ≥1
- `grep -c 'ghostty' .chezmoiignore` → ≥1
- `grep -c 'waystt' .chezmoiignore` → ≥1
- `grep -c 'mpv' .chezmoiignore` → ≥1
- `grep -c 'espanso' .chezmoiignore` → ≥1
- `grep -c '\.zshrc' .chezmoiignore` → ≥1
- `grep -c 'zsh/' .chezmoiignore` → ≥1 (but not matching .zsh_plugins.sh line)
- `grep -c '\.local/bin' .chezmoiignore` → ≥1
- `grep -c 'Windows Terminal' windows/INSTRUCTION.md` → 0
- `chezmoi apply --dry-run --force 2>&1 | grep -i error | grep -v 'ejson\|decrypt' | wc -l` → 0

## Tasks

- [x] **T01: Expand .chezmoiignore Windows exclusions + update INSTRUCTION.md** `est:10m`
  - Why: Linux/macOS-only configs deploy uselessly on Windows; WT TODO in docs is now automated
  - Files: `.chezmoiignore`, `windows/INSTRUCTION.md`
  - Do:
    1. Add a new `{{ if eq .chezmoi.os "windows" }}` block in `.chezmoiignore` (or expand the existing one) with all Linux/macOS-only target paths: `.config/btop/`, `.config/yakuakerc`, `.config/konsolerc`, `.config/ghostty/`, `.config/waystt/`, `.config/mpv/`, `.config/espanso/`, `.zshrc`, `zsh/`, `.local/bin/`
    2. Remove the WT configuration TODO block from `windows/INSTRUCTION.md` (the "Script to configure Windows Terminal" section with its sub-items)
    3. Verify all existing `.chezmoiignore` gates remain intact (karabiner, environment.d, etc.)
  - Verify:
    - All grep checks from Must-Haves section pass
    - `chezmoi apply --dry-run --force 2>&1 | grep -i error | grep -v 'ejson\|decrypt' | wc -l` → 0
    - Existing gates: `grep 'karabiner' .chezmoiignore` → match; `grep 'environment.d' .chezmoiignore` → match; `grep 'Documents' .chezmoiignore` → match
  - Done when: all verification commands pass; no regressions in existing gates

## Files Likely Touched

- `.chezmoiignore`
- `windows/INSTRUCTION.md`
