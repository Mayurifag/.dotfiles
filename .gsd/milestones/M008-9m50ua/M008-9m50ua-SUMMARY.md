---
id: M008-9m50ua
provides:
  - Chezmoi-managed Windows Terminal settings.json (Dracula, JetBrainsMono, quake globalSummon, startOnUserLogin, pwsh default)
  - run_once symlink from WT AppData path to chezmoi-managed settings
  - JetBrainsMono Nerd Font in Wingetfile
  - 10 Linux/macOS-only configs excluded from Windows via .chezmoiignore
  - WT configuration TODO removed from INSTRUCTION.md
key_decisions:
  - D025: WT settings.json at dot_config/windows-terminal/ with symlink to AppData
  - D026: Single-task slices
  - D027: globalSummon without _quake name — keeps tabs visible
  - D028: eq windows block for Linux/macOS exclusions (not ne linux)
patterns_established:
  - chezmoi source at dot_config/ + run_once mklink to deep AppData path
  - run_once PS script with Developer Mode prerequisite check
observability_surfaces:
  - "chezmoi managed --include=scripts | grep terminal"
  - "chezmoi cat ~/.config/windows-terminal/settings.json"
  - "grep -c 'btop\\|yakuakerc\\|ghostty' .chezmoiignore"
requirement_outcomes: []
duration: ~20m
verification_result: pass
completed_at: 2026-03-15
---

# M008-9m50ua: Windows Terminal Config + chezmoiignore Cleanup

**`chezmoi apply` on Windows delivers a fully configured Windows Terminal (JetBrainsMono, Dracula, quake mode on Ctrl+`, auto-start on login, pwsh default) via a symlinked settings.json, and `.chezmoiignore` is cleaned up so 10 Linux/macOS-only configs no longer deploy on Windows.**

## What Happened

S01 created `dot_config/windows-terminal/settings.json` with the complete WT configuration and `run_once_setup-windows-terminal.ps1` to symlink it from WT's deep AppData path. The settings include `startOnUserLogin: true` (quake mode works after boot), `globalSummon` on `ctrl+\`` without `_quake` name (tabs stay visible), Dracula color scheme, JetBrainsMono Nerd Font, and pwsh as default profile. `DEVCOM.JetBrainsMonoNerdFont` added to Wingetfile.

S02 added 10 Linux/macOS-only paths to the `eq windows` block in `.chezmoiignore` (btop, yakuakerc, konsolerc, ghostty, waystt, mpv, espanso, .zshrc, zsh/, .local/bin/) and removed the WT configuration TODO from INSTRUCTION.md.

## Cross-Slice Verification

All milestone success criteria verified:

| Criterion | Result |
|-----------|--------|
| settings.json has startOnUserLogin | ✓ |
| settings.json has JetBrainsMono | ✓ |
| settings.json has Dracula scheme | ✓ |
| settings.json has globalSummon | ✓ |
| JetBrainsMono in Wingetfile | ✓ |
| run_once script PS-valid | ✓ |
| .chezmoiignore has all 10 new exclusions | ✓ |
| WT TODO removed from INSTRUCTION.md | ✓ |
| chezmoi apply --dry-run zero errors | ✓ |
| Existing .chezmoiignore gates intact | ✓ |

## Forward Intelligence

### What the next milestone should know
- WT settings.json lives at `dot_config/windows-terminal/settings.json` — edit this file to change any WT configuration
- The run_once symlink script fires once per machine. If the script changes, rename it or clear chezmoi state bucket to re-run.
- `globalSummon` uses `ctrl+\`` (physical key VK_OEM_3) — works on both EN and RU layouts without needing separate bindings
- Developer Mode is a prerequisite for the symlink — init.ps1 step 2 enables it

### What's fragile
- WT settings.json is a full replacement — if WT adds new required schema fields in future versions, they'll get defaults (WT is backward-compatible)
- The PowerShell 7 GUID `{574e775e-4f2a-5b96-ac1e-a2962a402336}` is well-known but technically derived from the pwsh.exe path hash — if MS changes the derivation, the GUID may differ
- `DEVCOM.JetBrainsMonoNerdFont` winget ID may change if the publisher changes — verify with `winget search JetBrainsMono` if install fails

### Authoritative diagnostics
- `chezmoi cat ~/.config/windows-terminal/settings.json` — verify deployed content
- `chezmoi managed --include=scripts | grep terminal` — verify run_once script tracked
- `Get-Item "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" | Select-Object LinkType, Target` — verify symlink on Windows

## Files Created/Modified

- `dot_config/windows-terminal/settings.json` — new; complete WT config
- `run_once_setup-windows-terminal.ps1` — new; symlink creation script
- `install/Wingetfile` — added JetBrainsMono font, sorted alphabetically
- `.chezmoiignore` — added windows-terminal gate + 10 Windows exclusions
- `windows/INSTRUCTION.md` — WT TODO block removed
