---
id: T01
parent: S01
milestone: M008-9m50ua
provides:
  - dot_config/windows-terminal/settings.json — complete WT config (font, Dracula, quake, autostart, pwsh default)
  - run_once_setup-windows-terminal.ps1 — symlink from WT AppData path to chezmoi-managed settings
  - DEVCOM.JetBrainsMonoNerdFont in install/Wingetfile
  - .config/windows-terminal/ gated to Windows-only in .chezmoiignore
key_files:
  - dot_config/windows-terminal/settings.json
  - run_once_setup-windows-terminal.ps1
  - install/Wingetfile
  - .chezmoiignore
key_decisions:
  - "globalSummon without _quake name — regular window summon keeps tabs visible; _quake forces focus mode which hides tabs"
  - "Single ctrl+` binding — WT registers physical key (VK_OEM_3) for globalSummon, works regardless of keyboard layout"
  - "cmd /c mklink for symlink creation — standard Windows symlink approach, requires Developer Mode (already enabled by init.ps1)"
  - "Wingetfile sorted alphabetically — was previously unsorted"
patterns_established:
  - run_once PS script with Developer Mode check before symlink creation
  - chezmoi source at dot_config/ with symlink to deep AppData path via run_once script
duration: 15m
verification_result: pass
completed_at: 2026-03-15
---

# T01: WT settings.json + run_once symlink script + Wingetfile entry

**Complete Windows Terminal settings.json with Dracula theme, JetBrainsMono Nerd Font, pwsh default, quake-mode globalSummon on Ctrl+`, and startOnUserLogin — deployed via chezmoi to `~/.config/windows-terminal/` and symlinked to WT's AppData path by a run_once script.**

## What Happened

Created `dot_config/windows-terminal/settings.json` with all WT configuration. Key choices:

- **globalSummon without `_quake` name**: WT's `_quake` window forces focus mode (hides tabs). The user explicitly wanted tabs visible. Using `globalSummon` with `toggleVisibility: true` and `desktop: "toCurrent"` but without `name: "_quake"` gives the same summon/dismiss behavior with tabs preserved.
- **Single `ctrl+\`` binding**: WT's globalSummon uses `RegisterHotKey` internally, registering the physical key (VK_OEM_3). This works regardless of keyboard layout — pressing the physical backtick/ё key with Ctrl triggers the summon whether the active layout is EN or RU. The German keyboard layout fix (WT#10203) confirmed this behavior.
- **PowerShell 7 GUID**: Used the well-known GUID `{574e775e-4f2a-5b96-ac1e-a2962a402336}` as `defaultProfile`. Also listed Git Bash profile with its known GUID. Legacy Windows PowerShell and cmd are hidden.
- **Dracula scheme**: Standard Dracula hex values matching the official spec — consistent with the existing Konsole colorscheme in the repo.

The `run_once_setup-windows-terminal.ps1` script:
1. Guards on `$env:OS -ne 'Windows_NT'`
2. Checks Developer Mode is enabled (reads registry key)
3. Verifies source file exists (chezmoi must have deployed it) and WT LocalState directory exists (WT must have launched once)
4. If target is already a correct symlink → exits 0 (idempotent)
5. Backs up existing settings.json to `.bak`
6. Creates symlink via `cmd /c mklink`
7. Verifies creation succeeded

Wingetfile sorted alphabetically and `DEVCOM.JetBrainsMonoNerdFont` added. `.chezmoiignore` gates `.config/windows-terminal/` on non-Windows.

## Deviations

- Dropped `_quake` name from globalSummon — context specified it, but investigation revealed `_quake` forces focus mode hiding tabs, directly contradicting the user's requirement for visible tabs.
- Dropped second `ctrl+ё` / `ctrl+oem_3` keybinding — investigation showed WT globalSummon registers physical keys regardless of layout, making a second binding redundant.

## Files Created/Modified

- `dot_config/windows-terminal/settings.json` — new; 88 lines; complete WT config
- `run_once_setup-windows-terminal.ps1` — new; 72 lines; symlink creation with guards
- `install/Wingetfile` — added `DEVCOM.JetBrainsMonoNerdFont`, sorted alphabetically
- `.chezmoiignore` — added `.config/windows-terminal/` to `ne windows` gate
