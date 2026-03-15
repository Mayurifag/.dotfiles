# M006-mbvfvm: Kanata Cross-Platform Key Remapping

**Gathered:** 2026-03-15
**Status:** Queued — pending auto-mode execution

## Project Description

Add kanata keyboard remapping to the dotfiles — managed by chezmoi — so that CapsLock sends `Ctrl+Shift` (language switch shortcut) on Linux and Windows, without any manual install or configuration steps after `chezmoi apply`.

macOS is out of scope for now: karabiner-elements already handles CapsLock → Cmd+Space there and remains as-is. The door is left open for a future milestone that replaces karabiner-elements with kanata on macOS.

## Why This Milestone

- Linux: no current CapsLock remapping at all — the user has to switch languages without a dedicated key.
- Windows: the INSTRUCTION.md TODO already calls for migrating to kanata/komokana; currently no remapping tool is configured by chezmoi.
- karabiner-elements is macOS-only; espanso is for text expansion — neither covers cross-platform key remapping.
- kanata uses a single `.kbd` config file that works on all three platforms, making it the correct single-source-of-truth for key remapping in this repo.

## User-Visible Outcome

### When this milestone is complete, the user can:

- Press CapsLock on Linux and Windows and it sends `Ctrl+Shift` (triggering language switch), with no manual configuration
- Run `chezmoi apply` on a fresh Linux machine and have kanata installed (via Archfile), its config deployed, and a systemd user service enabled so it starts automatically on login
- Run `chezmoi apply` on a fresh Windows machine and have kanata_gui installed (via Wingetfile), its config deployed, and a Task Scheduler entry created (via run_once PS script) so it starts automatically on login
- Add new key remappings to a single `.kbd` file and have them apply on both Linux and Windows after `chezmoi apply` + kanata restart

### Entry point / environment

- Entry point: chezmoi apply (all setup); then key remapping is always-on via autostart
- Environment: Linux (primary; Arch-based), Windows (secondary; post-chezmoi-apply)
- Live dependencies involved: kanata daemon (Linux: systemd user service; Windows: Task Scheduler); kernel uinput module (Linux)

## Completion Class

- Contract complete means: `dot_config/kanata/kanata.kbd` tracked by chezmoi; kanata appears in Archfile and Wingetfile; systemd service unit file tracked by chezmoi (Linux); run_once PS script creates Task Scheduler entry (Windows)
- Integration complete means: `chezmoi apply` on Linux deploys config + service; `systemctl --user start kanata` works; CapsLock sends Ctrl+Shift
- Operational complete means: kanata service is enabled and starts on login automatically (Linux: systemctl --user enable; Windows: Task Scheduler trigger = AtLogon)

## Final Integrated Acceptance

To call this milestone complete, we must prove:

- On Linux: `chezmoi apply` deploys config; `systemctl --user status kanata` shows active/running; pressing CapsLock produces Ctrl+Shift
- On Linux: `systemctl --user is-enabled kanata` returns `enabled` (starts on login)
- On Windows: after `chezmoi apply`, Task Scheduler entry `kanata` exists with AtLogon trigger pointing to kanata_gui
- `chezmoi apply --dry-run` produces no errors
- Adding a new remap to `kanata.kbd` and running `chezmoi apply` + `systemctl --user restart kanata` applies it on Linux without manual file copying

## Risks and Unknowns

- **Linux uinput group membership** — kanata requires the user to be in the `input` and `uinput` groups (or run with sudo). A run_once script can add the user but group membership only takes effect on next login. The systemd service will fail on the first apply until the user re-logs in. This needs a clear note in the service or README. — *Expected; document it.*
- **Windows kanata_gui vs kanata-cli** — winget has `jtroo.kanata_gui` (GUI tray variant) and `jtroo.kanata` (headless). The GUI variant is easier for Windows autostart (tray icon, no console window). The headless CLI needs a wrapper to run silently. Prefer `jtroo.kanata_gui` to avoid a console window appearing at login.
- **Windows config path** — kanata_gui on Windows looks for config at `%APPDATA%\kanata\kanata.kbd` by default, but a config path can be passed as a CLI arg. The Task Scheduler entry should pass the full path to `~/.config/kanata/kanata.kbd` (which chezmoi deploys to `$HOME/.config/kanata/kanata.kbd`). Verify chezmoi deploys there on Windows or adjust path if needed.
- **Linux uinput module** — `uinput` module must be loaded. On Arch it is usually auto-loaded, but a `run_once` script or `modules-load.d` entry may be needed if kanata fails with "uinput not found".
- **macOS future** — karabiner.json and kanata.kbd can coexist in this repo in parallel because karabiner deploys only on macOS (`.chezmoiignore` gates it) and kanata deploys only on Linux/Windows. No conflict.

## Existing Codebase / Prior Art

- `.chezmoiignore` — `{{ if ne .chezmoi.os "darwin" }}` gates karabiner; same pattern will gate kanata config if needed (or deploy kanata.kbd everywhere and let the service/app manage it per-OS)
- `dot_config/private_karabiner/private_karabiner.json` — macOS CapsLock → Cmd+Space rule; reference for intent (CapsLock as language switch); kanata equivalent is `defsrc capslock` → `deflayer` with `(lctl lsft)` action
- `install/Archfile` — package list for Arch Linux; add `kanata` here
- `install/Wingetfile` — package list for Windows; add `jtroo.kanata_gui` here
- `run_once_remove-old-claude-install.sh` — established pattern for run_once bash scripts on Linux
- `windows/init.ps1` — Windows init PS script; run_once PS equivalent pattern for Task Scheduler creation
- `dot_local/share/konsole/shortcuts/Default` — example of chezmoi-managed `~/.local/share/` content (shows exact_ prefix not needed for single files)
- `windows/INSTRUCTION.md` — has `- [ ] Migrate to kanata/komokana` TODO; remove/update when milestone is done

> See `.gsd/DECISIONS.md` for all architectural and pattern decisions — it is an append-only register; read it during planning, append to it during execution.

## Relevant Requirements

- No existing REQUIREMENTS.md — new capability, no prior requirement contract.

## Scope

### In Scope

- `dot_config/kanata/kanata.kbd` — single shared kanata config file; CapsLock → `(lctl lsft)` (Ctrl+Shift); deployed by chezmoi to `~/.config/kanata/kanata.kbd` on Linux and Windows
- `install/Archfile` — add `kanata` package
- `install/Wingetfile` — add `jtroo.kanata_gui`
- `dot_local/share/systemd/user/kanata.service` — systemd user service unit; deployed on Linux only (gated via `.chezmoiignore` or inline OS condition); runs kanata pointing at `~/.config/kanata/kanata.kbd`
- `run_once_setup-kanata-linux.sh` — bash run_once script; adds user to `input` and `uinput` groups; enables + starts kanata service; loads `uinput` module if not loaded; Linux-only guarded via `uname -s`
- `run_once_setup-kanata-windows.ps1` — PS run_once script; creates a Task Scheduler task `kanata` that runs `kanata_gui.exe --cfg %USERPROFILE%\.config\kanata\kanata.kbd` at logon for the current user; Windows-only guarded appropriately
- Remove the `- [ ] Migrate to kanata/komokana` TODO from `windows/INSTRUCTION.md`

### Out of Scope / Non-Goals

- macOS: karabiner-elements stays; no kanata setup on macOS in this milestone
- Any additional key remappings beyond CapsLock → Ctrl+Shift — the config is extensible; future remaps are out of scope for this milestone
- Layer-based mappings, tap-hold, combos — future scope; the initial config is intentionally simple
- wayland-specific workarounds (wlroots compositor input passthrough) — kanata handles this at kernel level via uinput; no extra setup needed
- Espanso migration — the INSTRUCTION.md also mentions this; separate concern, separate milestone
- komokana (window manager keybinding layer for Windows) — separate tool; out of scope

## Technical Constraints

- kanata requires `uinput` kernel module and user membership in `input`/`uinput` groups on Linux — systemd service will fail until the user re-logs in after group add; document this clearly in service `ExecStartPre` or comments
- kanata_gui on Windows reads config from path passed via `--cfg` flag; the Task Scheduler entry must pass the correct path explicitly
- chezmoi deploys `dot_config/kanata/kanata.kbd` to `~/.config/kanata/kanata.kbd` on all OSes including macOS — this is fine; the file being present on macOS does not cause harm (karabiner-elements ignores it)
- The `.kbd` config syntax is identical across all platforms — one file, no OS branching needed in the config itself for the initial CapsLock mapping
- systemd user service (not system service) — runs as the logged-in user; no sudo required at runtime; `~/.local/share/systemd/user/kanata.service` is the chezmoi source path (maps to `~/.local/share/systemd/user/kanata.service`)
- run_once PS script must handle "task already exists" gracefully (idempotent) — use `Unregister-ScheduledTask -Confirm:$false -ErrorAction SilentlyContinue` before `Register-ScheduledTask`
- kanata.kbd `defsrc` must include `caps` (or `capslock` depending on kanata version) — verify exact key name in kanata docs at planning time

## Integration Points

- `kanata` daemon — reads `~/.config/kanata/kanata.kbd`; restarts on config change; managed by systemd (Linux) or Task Scheduler (Windows)
- `systemd --user` — user-level service manager on Linux; `kanata.service` unit lives in `~/.local/share/systemd/user/`
- Windows Task Scheduler — `schtasks` or `Register-ScheduledTask` PS cmdlet; AtLogon trigger for current user
- `uinput` kernel module — Linux; loaded automatically on most Arch installs but may need explicit load in edge cases
- `input`/`uinput` groups — Linux; `usermod -aG input,uinput $USER` in run_once script; requires re-login to take effect

## Open Questions

- **kanata.kbd key name for CapsLock** — is it `caps` or `capslock`? Check kanata docs during planning. Likely `caps` but confirm.
- **Windows config path at chezmoi apply time** — chezmoi deploys to `$USERPROFILE\.config\kanata\kanata.kbd` on Windows; confirm that `%USERPROFILE%\.config\kanata\kanata.kbd` is the correct Task Scheduler arg format (vs `$env:USERPROFILE`).
- **kanata_gui tray vs headless** — for the Windows Task Scheduler approach, kanata_gui may show a tray icon (acceptable) or may need `--hidden` flag to start silently; check at planning time.
