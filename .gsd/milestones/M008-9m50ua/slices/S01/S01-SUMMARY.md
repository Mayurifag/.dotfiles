---
id: S01
milestone: M008-9m50ua
provides:
  - dot_config/windows-terminal/settings.json — complete WT config (Dracula, JetBrainsMono, quake globalSummon, startOnUserLogin, pwsh default)
  - run_once_setup-windows-terminal.ps1 — symlink from WT AppData to chezmoi-managed settings
  - DEVCOM.JetBrainsMonoNerdFont in Wingetfile
  - .config/windows-terminal/ gated Windows-only in .chezmoiignore
key_decisions:
  - globalSummon without _quake name — tabs stay visible (D027 pending)
  - Single ctrl+` binding works across keyboard layouts via physical key registration
  - cmd /c mklink with Developer Mode check for file symlinks
patterns_established:
  - chezmoi dot_config/ source + run_once symlink to deep AppData path
  - run_once PS script with Developer Mode prerequisite check
observability_surfaces:
  - "chezmoi managed --include=scripts | grep terminal"
  - "chezmoi cat ~/.config/windows-terminal/settings.json | grep startOnUserLogin"
drill_down_paths:
  - .gsd/milestones/M008-9m50ua/slices/S01/tasks/T01-SUMMARY.md
duration: ~15m
verification_result: pass
completed_at: 2026-03-15
---

# S01: Windows Terminal Settings via Symlink

**Chezmoi-managed Windows Terminal settings.json with Dracula theme, JetBrainsMono Nerd Font, quake-mode hotkey (Ctrl+`), auto-start on login, and pwsh default profile — deployed to `~/.config/windows-terminal/` and symlinked to WT's AppData path by a run_once script.**

## What Happened

Single-task slice delivering four file changes. The settings.json contains the complete WT configuration with `startOnUserLogin: true`, `globalSummon` on `ctrl+\`` (without `_quake` name to keep tabs visible), Dracula color scheme, JetBrainsMono Nerd Font, and pwsh as default profile. The run_once script creates a symlink with Developer Mode verification, existing file backup, and idempotent behavior. JetBrainsMono Nerd Font added to Wingetfile. `.config/windows-terminal/` gated to Windows-only in `.chezmoiignore`.

## Files Created/Modified

- `dot_config/windows-terminal/settings.json` — new; complete WT config
- `run_once_setup-windows-terminal.ps1` — new; symlink creation script
- `install/Wingetfile` — added JetBrainsMono font, sorted alphabetically
- `.chezmoiignore` — added `.config/windows-terminal/` gate
