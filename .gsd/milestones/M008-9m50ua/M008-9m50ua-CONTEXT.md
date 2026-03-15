# M008-9m50ua: Windows Terminal Config + chezmoiignore Cleanup

**Gathered:** 2026-03-15
**Status:** Queued — pending auto-mode execution

## Project Description

Chezmoi-manage Windows Terminal's `settings.json` via a symlink strategy: the actual settings file lives at a clean chezmoi source path (`windows/terminal-settings.json`), and a `run_once` PowerShell script creates a symbolic link from WT's deep `AppData` path to it. The config includes JetBrainsMono font, Dracula color scheme, quake mode with `Ctrl+`` and `Ctrl+ё` hotkeys, `startOnUserLogin` for boot persistence, default PowerShell profile, and focus mode toggle in quake window. Additionally, clean up `.chezmoiignore` to gate Linux/macOS-only configs from deploying on Windows.

## Why This Milestone

After boot, quake mode hotkey doesn't work because Windows Terminal isn't running — there's no autostart configured. Beyond that, the INSTRUCTION.md has a long-standing TODO block for WT configuration (font, theme, quake hotkey, default profile) that requires manual GUI clicking every fresh install. Chezmoi-managing the settings.json eliminates this entirely.

The `.chezmoiignore` cleanup is overdue — configs like btop, yakuakerc, konsolerc, ghostty, waystt, mpv, espanso, zsh files, and Linux desktop entries all deploy to Windows where they serve no purpose. This adds noise to `chezmoi apply` output and creates meaningless files on Windows.

## User-Visible Outcome

### When this milestone is complete, the user can:

- Boot a Windows machine and have Windows Terminal auto-start (minimized/tray), with quake mode responding to `Ctrl+`` / `Ctrl+ё` immediately — no manual launch needed
- Run `chezmoi apply` on a fresh Windows install and get a fully configured Windows Terminal: JetBrainsMono font, Dracula theme, pwsh default profile, quake mode hotkeys — zero manual GUI configuration
- Run `chezmoi apply` on Windows and see a cleaner diff with no Linux/macOS-only files polluting the output

### Entry point / environment

- Entry point: `chezmoi apply` on Windows (deploys settings + fires run_once symlink script)
- Environment: Windows local dev; Windows Terminal (Store version)
- Live dependencies involved: Windows Terminal must be installed (already in Wingetfile as `Microsoft.WindowsTerminal`)

## Completion Class

- Contract complete means: `windows/terminal-settings.json` exists in chezmoi source with all required settings; run_once script creates the symlink; `.chezmoiignore` gates all identified Linux/macOS-only paths on Windows
- Integration complete means: `chezmoi apply` on Windows creates the symlink and WT reads the settings correctly; `chezmoi apply` on Linux is unaffected (no regressions)
- Operational complete means: after boot, WT starts automatically and quake mode hotkey works without manual intervention

## Final Integrated Acceptance

To call this milestone complete, we must prove:

- On Windows: `chezmoi apply` deploys `windows/terminal-settings.json` to chezmoi target dir and the run_once script creates a symlink from `%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json` pointing to the chezmoi-managed file
- On Windows: Windows Terminal reads the symlinked settings — JetBrainsMono font, Dracula scheme, quake hotkey `Ctrl+`` all functional
- On Windows: `startOnUserLogin` is `true` in the settings — WT starts on boot, quake hotkey works immediately after login
- On Linux: `chezmoi apply --dry-run` produces no errors and no regressions from `.chezmoiignore` changes
- On Windows: `chezmoi apply --dry-run` no longer shows btop, yakuakerc, konsolerc, ghostty, waystt, mpv, espanso, zsh, or .local/share/applications entries
- INSTRUCTION.md WT TODO block is removed/updated

## Risks and Unknowns

- **Symlink creation requires elevation or Developer Mode** — on Windows, creating symlinks via `New-Item -ItemType SymbolicLink` or `mklink` requires either Administrator privileges or Developer Mode enabled. The `init.ps1` runs as admin, but the `run_once` scripts run during `chezmoi apply` as a normal user. If Developer Mode is not enabled, the symlink creation will fail. Need to either: (a) document that Developer Mode must be enabled, (b) fall back to a junction (doesn't need admin for directories but settings.json is a file, not a directory), or (c) use `cmd /c mklink` which may work differently. This is the biggest risk.
- **WT settings.json schema versioning** — Windows Terminal updates may change the settings schema. Using a static settings.json means future WT updates could introduce new required fields or deprecate existing ones. Mitigation: WT is backward-compatible and ignores unknown fields; missing new fields get defaults.
- **WT settings.json location for Store vs Preview vs Dev builds** — the package family name (`Microsoft.WindowsTerminal_8wekyb3d8bbwe`) is for the stable Store version. Preview and Dev builds have different package names. Only the stable build is in Wingetfile, so this is fine.
- **Symlink target path** — chezmoi deploys `windows/terminal-settings.json` to `~/windows/terminal-settings.json` on the target machine. But `windows/` is in `.chezmoiignore` (excluded from all OSes). The file needs to live at a chezmoi-managed path that actually deploys on Windows. Options: (a) put it under a new Windows-only source path, (b) use a chezmoi template path that deploys on Windows only, (c) the run_once script downloads it from GitHub raw. Need to resolve the source path — the file must be at a location chezmoi actually deploys to on Windows.
- **Existing WT settings.json** — if the user has already customized WT settings, the symlink will replace them. The run_once script should back up the existing file before creating the symlink.

## Existing Codebase / Prior Art

- `windows/INSTRUCTION.md` — contains the WT TODO block (font, quake, Dracula, default profile, focus mode); to be cleared
- `.chezmoiignore` — current gates: karabiner (ne darwin), environment.d/applications/konsole/systemd (ne linux), run_after_cz_apply.sh (eq windows), Documents (ne windows); needs expansion for Windows exclusions
- `dot_config/yakuakerc` — Linux Yakuake config (quake-mode terminal on KDE); parallel to WT on Windows; to be gated
- `dot_config/private_konsolerc` — Linux Konsole config; to be gated
- `dot_config/btop/` — btop config and themes; Linux-only in practice; to be gated
- `dot_config/ghostty/` — Ghostty terminal config; Linux/macOS only (no Windows build); to be gated
- `dot_config/waystt/` — Wayland terminal config; Linux only; to be gated
- `dot_config/mpv/` — mpv media player config; Linux-focused; to be gated
- `dot_config/exact_espanso/` — Espanso text expander config; to be gated (separate TODO exists for making espanso work on Windows)
- `exact_zsh/` — zsh config directory; Linux/macOS only; to be gated
- `dot_zshrc` — zsh config; Linux/macOS only; to be gated
- `dot_local/share/konsole/` — already gated (ne linux)
- `dot_local/share/applications/` — already gated (ne linux)
- `dot_local/bin/` — contains only `.keep`; to be gated (Linux-only)
- `run_once_setup-kanata-windows.ps1` — established pattern for run_once PS scripts on Windows
- `run_once_setup-kanata-linux.sh` — established pattern for run_once bash scripts on Linux
- `dot_local/share/konsole/klorax.dracula-transparent.colorscheme` — Dracula color values reference for translating to WT JSON format

> See `.gsd/DECISIONS.md` for all architectural and pattern decisions — it is an append-only register; read it during planning, append to it during execution.

## Relevant Requirements

- None registered — new capability; clears existing INSTRUCTION.md TODOs.

## Scope

### In Scope

- Create `windows/terminal-settings.json` (or equivalent chezmoi-deployed path) containing:
  - `"startOnUserLogin": true` (global setting — WT starts on boot)
  - Default profile set to PowerShell 7 (pwsh) GUID
  - `"font.face": "JetBrainsMono Nerd Font"` in default profile settings
  - Dracula color scheme definition (translate from existing Konsole Dracula colorscheme)
  - Default profile uses Dracula color scheme
  - Global quake mode hotkeys: `Ctrl+`` (globalSummon with `"name": "_quake"`) and `Ctrl+ё` (Russian layout equivalent)
  - Focus mode toggle in quake window (so tabs are visible)
- Create a `run_once` PowerShell script that:
  - Backs up existing `settings.json` if present (rename to `settings.json.bak`)
  - Creates a symbolic link from `%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json` → chezmoi-managed settings file
  - Handles the case where the symlink already exists (idempotent)
  - Windows-only guarded
- Clean up `.chezmoiignore` — add to the `ne windows` (i.e., exclude on Windows) block:
  - `.config/btop/`
  - `.config/yakuakerc`
  - `.config/konsolerc`
  - `.config/ghostty/`
  - `.config/waystt/`
  - `.config/mpv/`
  - `.config/espanso/`
  - `.zshrc`
  - `zsh/` (covers `exact_zsh/`)
  - `.local/bin/`
- Update `windows/INSTRUCTION.md` — remove the WT configuration TODO block (font, quake, Dracula, default profile, focus mode)
- Verify `chezmoi apply --dry-run` on Linux produces no regressions

### Out of Scope / Non-Goals

- Customizing WT beyond the listed settings (tabs, panes, keybindings beyond quake)
- WT Preview or Dev build support — stable Store version only
- Making espanso work on Windows (separate TODO, separate milestone)
- AutoHotkey configuration (separate TODO in INSTRUCTION.md)
- Modifying any Linux config files — this is Windows-only delivery + ignore cleanup

## Technical Constraints

- Symlink creation on Windows requires Developer Mode enabled or Administrator elevation — the run_once script runs as the current user during `chezmoi apply`; if Developer Mode is off, `New-Item -ItemType SymbolicLink` will fail with "Insufficient privilege." The script must detect this and provide a clear error message with instructions to enable Developer Mode.
- `windows/` directory is in `.chezmoiignore` (excluded from all platforms) — the settings.json source file cannot live at `windows/terminal-settings.json` because chezmoi won't deploy it. Need an alternative chezmoi-managed path that deploys on Windows only. Options: a dedicated `AppData/` source directory gated to Windows in `.chezmoiignore`, or embed the settings content in the run_once script itself.
- WT `settings.json` uses JSONC (JSON with comments) — the file may contain comments; standard JSON parsers may choke. Authoring as plain JSON (no comments) avoids this.
- The `globalSummon` action requires the `"keys"` field to use WT keybinding syntax (e.g., `"ctrl+\u0060"` for backtick)
- PowerShell 7 GUID in WT is `{574e775e-4f2a-5b96-ac1e-a2962a402336}` (well-known; derived from the pwsh.exe path hash by WT) — but this may vary; safer to use `"commandline": "pwsh.exe"` in the default profile definition and let WT resolve it
- `.chezmoiignore` uses chezmoi target paths (not source paths) — `zsh/` in ignore maps to `exact_zsh/` source; `.zshrc` maps to `dot_zshrc` source

## Integration Points

- `Windows Terminal` — reads `settings.json` from `%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\`; symlink makes it read from chezmoi-managed location
- `chezmoi` — deploys the settings file and fires the run_once symlink script during `chezmoi apply`
- `JetBrainsMono Nerd Font` — must be installed on the system; already handled by `init.ps1` which installs nerd fonts or by the user's font setup; verify it's in Wingetfile or document as prerequisite
- `.chezmoiignore` — controls which files deploy on which OS; changes affect all three platforms

## Open Questions

- **Source file path for settings.json** — since `windows/` is in `.chezmoiignore`, the settings.json can't live there and be deployed by chezmoi. Best options: (a) embed the full JSON content in the run_once script itself (simplest — one file, no path gymnastics), (b) create an `AppData/Local/` source directory in chezmoi gated to Windows only, (c) move it to `dot_config/windows-terminal/settings.json` and symlink from there. Need to decide during planning. Option (a) is pragmatic since the script already needs to handle symlink creation — embedding the content avoids a second file and a second deployment concern.
- **JetBrainsMono Nerd Font installation** — is this font already installed by `init.ps1` or Wingetfile? If not, it needs to be added. Check at planning time.
- **Focus mode in quake** — the INSTRUCTION.md says "Quake mode has to toggle focus mode so tabs will be seen." WT's quake window defaults to focus mode (hides tabs). The `"name": "_quake"` profile can set `"tabBar.visibility": "always"` or the globalSummon action can toggle focus mode. Verify exact WT settings during planning.
