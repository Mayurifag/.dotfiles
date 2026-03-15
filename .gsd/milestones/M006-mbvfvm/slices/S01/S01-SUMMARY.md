---
id: S01
milestone: M006-mbvfvm
provides:
  - dot_config/kanata/kanata.kbd — CapsLock → Ctrl+Shift remap; single file deployed on all platforms
  - dot_local/share/systemd/user/kanata.service — systemd user service; Linux-only via .chezmoiignore
  - run_once_setup-kanata-linux.sh — adds user to input/uinput groups, loads uinput module, enables + starts service
  - run_once_setup-kanata-windows.ps1 — sets HKCU Run registry key for kanata_gui with --cfg path
  - install/Archfile — kanata added; install/Wingetfile — jtroo.kanata_gui added
key_decisions:
  - D019: single slice for M006-mbvfvm
  - D020: Windows autostart via registry Run key (not Task Scheduler)
  - D021: (multi lctl lsft) as CapsLock deflayer action
  - D022: systemd service gated Linux-only via .chezmoiignore
  - process-unmapped-keys yes in defcfg — ensures all non-remapped keys pass through normally
patterns_established:
  - run_once PS script: guard with $env:OS -ne 'Windows_NT' (not uname/which); $env:USERPROFILE for config path
  - systemd ExecStart uses %h (systemd home dir specifier) — not $HOME — for reliability in user service context
key_files:
  - dot_config/kanata/kanata.kbd
  - dot_local/share/systemd/user/kanata.service
  - run_once_setup-kanata-linux.sh
  - run_once_setup-kanata-windows.ps1
  - install/Archfile
  - install/Wingetfile
  - .chezmoiignore
duration: ~45m
verification_result: pass
completed_at: 2026-03-15
---

# S01: Ship kanata config, Linux autostart, and Windows autostart

**All deliverables shipped: kanata.kbd, systemd service, two run_once scripts, install entries — `chezmoi apply --dry-run` produces zero errors; CapsLock → Ctrl+Shift remap ready for live use after kanata install.**

## What Happened

**T01 (kanata.kbd + install entries):** Created `dot_config/kanata/kanata.kbd` with minimal config: `(defcfg process-unmapped-keys yes)`, `(defsrc caps)`, `(deflayer default (multi lctl lsft))`. Added `kanata` to `install/Archfile` (alphabetical) and `jtroo.kanata_gui` to `install/Wingetfile`. The `process-unmapped-keys yes` directive is essential — without it kanata would block all keys not listed in `defsrc`.

**T02 (systemd service + .chezmoiignore gate):** Created `dot_local/share/systemd/user/kanata.service` using `ExecStart=kanata --cfg %h/.config/kanata/kanata.kbd` (`%h` is the systemd specifier for the user's home directory — more reliable than $HOME in service context). Service description includes a clear NOTE about the re-login requirement for group membership. Added `.local/share/systemd/` to the `ne linux` block in `.chezmoiignore` — consistent with the existing pattern that gates `.local/share/applications/` and `.local/share/konsole/` for Linux-only.

**T03 (Linux run_once):** `run_once_setup-kanata-linux.sh` — guarded with `[ "$(uname -s)" = "Linux" ] || exit 0`, adds user to `input` and `uinput` groups via `sudo usermod -aG`, writes `uinput` to `/etc/modules-load.d/uinput.conf` for boot persistence, loads the module immediately with `modprobe`, daemon-reloads systemd, enables + starts the service (start may fail on first run due to group membership not yet active — this is expected and documented in the service unit and script output).

**T04 (Windows run_once):** `run_once_setup-kanata-windows.ps1` — guarded with `if ($env:OS -ne 'Windows_NT') { exit 0 }`, searches for `kanata_gui.exe` in winget packages directory first, falls back to PATH, then falls back to bare name. Sets `HKCU:\Software\Microsoft\Windows\CurrentVersion\Run` key `Kanata` pointing to `"<exe>" --cfg "<USERPROFILE>\.config\kanata\kanata.kbd"`. Removed `- [ ] Migrate to kanata/komokana` TODO from `windows/INSTRUCTION.md`.

## Deviations

None — all tasks executed as planned.

## Files Created/Modified

- `dot_config/kanata/kanata.kbd` — kanata config; CapsLock → `(multi lctl lsft)`
- `install/Archfile` — added `kanata`
- `install/Wingetfile` — added `jtroo.kanata_gui`
- `dot_local/share/systemd/user/kanata.service` — systemd user service unit
- `.chezmoiignore` — added `.local/share/systemd/` to Linux-only gate
- `run_once_setup-kanata-linux.sh` — Linux group/module/service setup
- `run_once_setup-kanata-windows.ps1` — Windows registry Run key setup
- `windows/INSTRUCTION.md` — removed kanata/komokana migration TODO
