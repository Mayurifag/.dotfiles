# S02: chezmoiignore Cleanup + Docs — UAT

## Checks

### 1. Windows: no Linux configs deployed
After `chezmoi apply` on Windows, verify these paths do NOT exist in `~/.config/`:
- `btop/`
- `yakuakerc`
- `konsolerc`
- `ghostty/`
- `waystt/`
- `mpv/`
- `espanso/`

And these do NOT exist in `~/`:
- `.zshrc`
- `zsh/`
- `.local/bin/`

### 2. Linux: no regressions
Run `chezmoi apply --dry-run` on Linux. All existing configs should still be listed for deployment. No errors.

### 3. INSTRUCTION.md
Open `windows/INSTRUCTION.md`. The "Script to configure Windows Terminal" TODO block should be gone. Other TODOs (VSCode, browser, gitkraken, PowerToys, espanso, autohotkey, mise winget backend) should still be present.
