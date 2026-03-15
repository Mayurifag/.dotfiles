# M009: Kanata Typography Layer + AHK Cleanup

**Gathered:** 2026-03-15
**Status:** Queued — pending auto-mode execution

## Project Description

Migrate the RAlt typography mappings (Birman layout: em-dash, arrows, «», ™, etc.) from the Windows-only AutoHotkey script into kanata for both Linux and Windows. Remove the CapsLock mapping from kanata (CapsLock is handled by AHK on Windows and KDE/xkb on Linux — not kanata's concern). Clean up the AHK script to remove the typography section and commented-out experiments. Set up AHK as chezmoi-aware with a Windows Startup shortcut. Fix kanata so it actually runs on Windows (the registry Run key currently points to `kanata_gui` which doesn't resolve — the actual binary is `kanata_windows_gui_winIOv2_x64.exe`).

## Why This Milestone

Three problems converge here:

1. **Typography mappings are Windows-only** — the RAlt Birman layout shortcuts (18 mappings: em-dash, ±, «», ™, ®, arrows, etc.) only work via AHK on Windows. Linux has no equivalent. Kanata can handle these cross-platform via `unicode` actions and a `layer-while-held` on RAlt.

2. **Kanata isn't actually running on Windows** — M006 created the registry Run key and config, but the key points to `"kanata_gui"` (bare name). The actual winget-installed binary is `kanata_windows_gui_winIOv2_x64.exe` in the WinGet Links directory. The consolidated `run_once_after_setup-windows.ps1` searches for `kanata_gui.exe` which also doesn't match. Kanata has never successfully auto-started on this machine.

3. **AHK is installed but not chezmoi-managed** — the INSTRUCTION.md has a stale TODO for "Autohotkey cfg: copied onto repo and script to Startup to launch." AHK is installed (`AutoHotkey.AutoHotkey 2.0.19` via winget) and the script lives at `windows/ahkv2.ahk` in the repo, but there's no autostart mechanism and the TODO has never been cleared.

## User-Visible Outcome

### When this milestone is complete, the user can:

- Press RAlt+hyphen to get an em-dash (—) on both Linux and Windows, with all 18 Birman typography shortcuts working cross-platform via kanata
- See kanata_gui running in the system tray on Windows after login (actually working, not silently failing)
- See the AHK script auto-launched at Windows login via a Startup shortcut pointing to the chezmoi source repo copy
- Have a clean AHK script with only CapsLock/Dota logic (no typography, no commented-out experiments)

### Entry point / environment

- Entry point: `chezmoi apply` on Windows (deploys kanata config + fixes registry key + creates AHK startup shortcut); `chezmoi apply` on Linux (deploys kanata config)
- Environment: Windows local dev (primary), Linux local dev (secondary)
- Live dependencies involved: kanata daemon (both platforms), AutoHotkey v2 (Windows only)

## Completion Class

- Contract complete means: `kanata.kbd` contains RAlt typography layer with all 18 unicode mappings; CapsLock mapping removed; AHK script has typography section removed and commented experiments removed; `run_once` script fixed for kanata exe resolution; AHK startup shortcut created; `AutoHotkey.AutoHotkey` in Wingetfile
- Integration complete means: kanata actually starts on Windows and the RAlt typography mappings produce correct unicode characters; AHK starts on login and CapsLock/Dota behavior works; both kanata and AHK coexist without conflict (kanata handles RAlt layer, AHK handles CapsLock)
- Operational complete means: after boot on Windows, both kanata_gui (tray) and AHK are running; on Linux, kanata service is running with the updated config

## Final Integrated Acceptance

To call this milestone complete, we must prove:

- On Windows: kanata_gui is actually running (process visible) after manual launch or re-login, reading the updated config
- On Windows: pressing RAlt+hyphen produces — (em-dash) in a text editor (kanata typography layer working)
- On Windows: AHK is running and CapsLock sends Ctrl+Shift outside Dota (AHK CapsLock logic still works)
- On Windows: kanata and AHK don't conflict — kanata handles RAlt, AHK handles CapsLock, neither intercepts the other's keys
- On Linux: `chezmoi apply --dry-run` produces no errors; kanata config renders correctly with typography layer
- On Linux: kanata service restarts cleanly with the new config (if kanata is running)
- AHK script no longer contains any RAlt typography mappings or commented-out Win+Space experiments
- `windows/ahkv2.ahk` is the single source for AHK; startup shortcut points to the chezmoi source repo path

## Risks and Unknowns

- **Windows AltGr handling** — On Windows, RAlt generates a phantom LCtrl press (AltGr behavior). Kanata needs `windows-altgr cancel-lctl-press` in `defcfg` to suppress this. Without it, the RAlt typography layer won't work correctly because kanata will see LCtrl+RAlt instead of just RAlt. This is a known kanata config option — low risk but must not be forgotten.
- **Unicode output method differs by platform** — On Linux, kanata uses Ctrl+Shift+U hex Enter (GTK/IBus method). On Windows, kanata likely uses a different method (possibly SendInput with Unicode flag). Unicode output may not work in all applications on either platform. Need to test in a real text editor.
- **kanata.kbd as template vs plain file** — The `platform(win)` and `platform(linux)` blocks in kanata are native kanata syntax, not chezmoi template syntax. The `windows-altgr cancel-lctl-press` config is Windows-only but kanata's own `platform` block handles this. The `.kbd` file likely does NOT need to be a chezmoi template — kanata's native platform conditionals should suffice. If any chezmoi-specific data is needed (e.g., paths from chezmoi data), then convert to `.tmpl`.
- **AHK and kanata key interception order** — kanata intercepts at the driver level (WinIOv2) before AHK sees keys. Since kanata will only remap RAlt (as a layer activator) and pass CapsLock through unchanged (`process-unmapped-keys yes`), AHK should see CapsLock normally. RAlt will be consumed by kanata for the typography layer. This should work but needs verification — if kanata's `layer-while-held` on RAlt still passes the RAlt keypress through, AHK might see it too.
- **Startup shortcut path** — The shortcut will point to `~/.local/share/chezmoi/windows/ahkv2.ahk` (the repo source path). This assumes the chezmoi source dir is always at this path. On a standard chezmoi install this is true, but if the user ever moves the source dir, the shortcut breaks. Acceptable for a personal dotfiles setup.
- **kanata_gui exe name mismatch** — The current run_once script searches for `kanata_gui.exe` but the winget-installed binary is `kanata_windows_gui_winIOv2_x64.exe`. The fix must search for `kanata*gui*` or use the WinGet Links path directly. The WinGet Links directory (`%LOCALAPPDATA%\Microsoft\WinGet\Links\`) contains a symlink `kanata_windows_gui_winIOv2_x64.exe` → the actual package binary.

## Existing Codebase / Prior Art

- `dot_config/kanata/kanata.kbd` — current kanata config; has only CapsLock→Ctrl+Shift; needs CapsLock removed and RAlt typography layer added
- `windows/ahkv2.ahk` — current AHK script; has CapsLock/Dota logic + RAlt typography + commented experiments; typography section to be removed
- `run_once_after_setup-windows.ps1` — consolidated Windows setup script; section 2 (Kanata) searches for `kanata_gui.exe` which doesn't match the actual binary name; needs fixing
- `.chezmoiignore` — `windows/` is excluded from chezmoi deployment (listed in ignore); the AHK script stays in the repo source only, not deployed to a target path
- `install/Wingetfile` — has `jtroo.kanata_gui`; needs `AutoHotkey.AutoHotkey` added
- `dot_local/share/systemd/user/kanata.service` — Linux systemd service; no change needed (points to `~/.config/kanata/kanata.kbd`)
- `run_once_setup-kanata-linux.sh` — Linux kanata setup; no change needed
- `windows/INSTRUCTION.md` — has TODO "Autohotkey cfg: copied onto repo and script to Startup to launch"; to be cleared

> See `.gsd/DECISIONS.md` for all architectural and pattern decisions — it is an append-only register; read it during planning, append to it during execution.

## Relevant Requirements

- None registered — new capability (cross-platform typography) + maintenance (fix kanata, set up AHK autostart).

## Scope

### In Scope

- **kanata.kbd rewrite**: Remove CapsLock mapping. Add `ralt` to `defsrc`. Create a `typography` layer activated by `layer-while-held` on RAlt. Map all 18 Birman typography shortcuts as `unicode` actions. Add `windows-altgr cancel-lctl-press` in a `platform(win)` block (or in main `defcfg` — it's harmless on Linux).
- **AHK script cleanup**: Remove the entire `RAlt &` typography section (18 mappings). Remove the commented-out Win+Space/LWin swap rules. Keep all CapsLock logic (plain CapsLock, Shift+CapsLock, Ctrl+CapsLock, Dota window detection) exactly as-is.
- **Fix kanata exe resolution**: Update section 2 of `run_once_after_setup-windows.ps1` to search for the actual binary name pattern (`kanata*gui*` or check WinGet Links directory for `kanata_windows_gui_winIOv2_x64.exe`). Update the registry Run key value accordingly.
- **AHK autostart**: Add a section to `run_once_after_setup-windows.ps1` that creates a Windows Startup folder shortcut (`.lnk` file in `shell:startup`) pointing to `~/.local/share/chezmoi/windows/ahkv2.ahk`. AutoHotkey v2 is the registered handler for `.ahk` files.
- **Wingetfile**: Add `AutoHotkey.AutoHotkey`.
- **INSTRUCTION.md**: Remove the AHK TODO.
- **Verify kanata runs**: After fixing the registry key, manually launch kanata_gui with the updated config on this Windows machine to confirm it starts and the typography layer works.

### Out of Scope / Non-Goals

- CapsLock handling in kanata — fully delegated to AHK (Windows) and KDE/xkb (Linux)
- Dota-specific layer switching in kanata — AHK handles Dota CapsLock behavior
- Converting kanata.kbd to a chezmoi template (`.tmpl`) — kanata's native `platform()` blocks handle OS-specific config
- macOS kanata setup — karabiner-elements handles macOS; kanata.kbd deploys there but is unused
- Any changes to the Linux kanata systemd service or setup script
- Adding new typography mappings beyond the existing 18 from the AHK script

## Technical Constraints

- `windows-altgr cancel-lctl-press` is required in `defcfg` for RAlt to work as a clean layer activator on Windows; without it, Windows sends LCtrl+RAlt for the RAlt key, which confuses kanata's layer detection
- kanata `unicode` action uses different input methods per platform: Linux uses Ctrl+Shift+U hex Enter (GTK/IBus); Windows uses its own method. Both are built into kanata — no user configuration needed, but application support may vary.
- The `process-unmapped-keys yes` directive must remain — it ensures keys not in `defsrc` (including CapsLock, after removal from defsrc) pass through to AHK and other applications unchanged
- kanata.kbd file encoding must be UTF-8 — the unicode character literals in `(unicode ...)` actions require it
- AHK `.lnk` shortcut creation in PowerShell requires `WScript.Shell` COM object or `New-Object -ComObject WScript.Shell` — standard approach for creating shortcuts programmatically
- The WinGet Links directory (`%LOCALAPPDATA%\Microsoft\WinGet\Links\`) is on PATH after winget install, so the exe name there should be resolvable — but the registry Run key needs the full path for reliability at login time before PATH is fully loaded

## Integration Points

- **kanata** — reads `~/.config/kanata/kanata.kbd`; handles RAlt typography layer on both platforms; must coexist with AHK on Windows (each handling different keys)
- **AutoHotkey v2** — reads `windows/ahkv2.ahk` from chezmoi source; handles CapsLock/Dota on Windows; launched via Startup shortcut
- **chezmoi** — deploys kanata.kbd to `~/.config/kanata/`; fires `run_once_after_setup-windows.ps1` which sets up kanata registry key and AHK startup shortcut
- **winget** — installs both `jtroo.kanata_gui` and `AutoHotkey.AutoHotkey`
- **systemd** (Linux) — kanata.service runs the daemon; needs restart after config change to pick up new typography layer

## Open Questions

- None — scope is settled from discussion.
