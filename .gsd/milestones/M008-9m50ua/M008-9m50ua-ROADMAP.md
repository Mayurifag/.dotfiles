# M008-9m50ua: Windows Terminal Config + chezmoiignore Cleanup

**Vision:** `chezmoi apply` on Windows delivers a fully configured Windows Terminal (JetBrainsMono font, Dracula theme, quake mode with Ctrl+`/Ctrl+ё, auto-start on login, pwsh as default profile) via a symlinked settings.json, and `.chezmoiignore` is cleaned up so Linux/macOS-only configs no longer deploy on Windows.

## Success Criteria

- Windows Terminal launches on boot (via `startOnUserLogin`) and quake mode responds to `Ctrl+`` / `Ctrl+ё` immediately — no manual launch needed
- `chezmoi apply` on a fresh Windows machine produces a fully configured WT with JetBrainsMono Nerd Font, Dracula color scheme, pwsh default profile, and quake hotkeys — zero manual GUI configuration
- `chezmoi apply` on Windows no longer deploys Linux/macOS-only configs (btop, yakuakerc, konsolerc, ghostty, waystt, mpv, espanso, zsh, .local/bin)
- `chezmoi apply --dry-run` on Linux produces no errors and no regressions from any changes

## Key Risks / Unknowns

- **Symlink requires Developer Mode** — `New-Item -ItemType SymbolicLink` for files requires Developer Mode enabled. `init.ps1` step 2 already enables this, but a user who skipped init.ps1 would hit "Insufficient privilege." The run_once script must detect this and fail with a clear message.
- **WT globalSummon Ctrl+ё** — The Russian-layout equivalent of backtick is `ё`. WT keybinding syntax for this needs verification — it may need a virtual key code or `oem3` rather than the literal character.

## Proof Strategy

- Symlink + Developer Mode → retire in S01 by proving the run_once script creates the symlink and WT reads settings from it
- Ctrl+ё keybinding → retire in S01 by authoring the globalSummon action and verifying WT accepts it

## Verification Classes

- Contract verification: file exists at chezmoi source path, settings.json contains all required keys (font, scheme, quake, autostart), `.chezmoiignore` has all new gates, `chezmoi apply --dry-run` clean on Linux
- Integration verification: on Windows, symlink exists and WT reads the symlinked settings (correct font, theme, quake hotkey visible in WT settings GUI)
- Operational verification: after reboot, WT starts automatically and quake hotkey works without manual launch
- UAT / human verification: press Ctrl+` and Ctrl+ё on Windows to confirm quake mode toggles; visually confirm font and theme

## Milestone Definition of Done

This milestone is complete only when all are true:

- `settings.json` is deployed by chezmoi and symlinked to WT's AppData path via run_once script
- WT settings contain: `startOnUserLogin: true`, JetBrainsMono Nerd Font, Dracula scheme, pwsh default profile, globalSummon with `Ctrl+`` and `Ctrl+ё`
- `.chezmoiignore` excludes all identified Linux/macOS-only paths on Windows
- `chezmoi apply --dry-run` on Linux produces zero errors and zero regressions
- `JetBrainsMono Nerd Font` is in the Wingetfile (or init.ps1 installs it)
- `windows/INSTRUCTION.md` WT TODO block is removed
- Success criteria re-checked against live state on both Linux and Windows

## Requirement Coverage

- Covers: none (no REQUIREMENTS.md exists)
- Orphan risks: none

## Slices

- [x] **S01: Windows Terminal Settings via Symlink** `risk:medium` `depends:[]`
  > After this: `chezmoi apply` on Windows deploys a fully configured Windows Terminal with JetBrainsMono font, Dracula theme, quake mode hotkeys (Ctrl+`/Ctrl+ё), auto-start on login, and pwsh as default profile — all via a symlinked settings.json.

- [x] **S02: chezmoiignore Cleanup + Docs** `risk:low` `depends:[]`
  > After this: `chezmoi apply` on Windows no longer deploys Linux/macOS-only configs (btop, yakuakerc, konsolerc, ghostty, waystt, mpv, espanso, zsh, .local/bin), and `windows/INSTRUCTION.md` WT TODO block is removed.

## Boundary Map

### S01 (standalone)

Produces:
- `dot_config/windows-terminal/settings.json` — complete WT settings file with font, Dracula scheme, quake globalSummon, startOnUserLogin, pwsh default profile
- `run_once_setup-windows-terminal.ps1` — symlink creation script from WT AppData path → chezmoi-managed settings.json
- `.chezmoiignore` gate for `.config/windows-terminal/` (non-Windows excluded)
- `JetBrainsMono Nerd Font` entry in `install/Wingetfile`

Consumes:
- nothing (first slice)

### S02 (standalone)

Produces:
- `.chezmoiignore` expanded with all Linux/macOS-only path exclusions for Windows
- `windows/INSTRUCTION.md` with WT TODO block removed

Consumes:
- nothing (independent of S01)
