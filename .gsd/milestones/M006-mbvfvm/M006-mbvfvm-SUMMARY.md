---
id: M006-mbvfvm
provides:
  - Chezmoi-managed kanata keyboard remapping: CapsLock → Ctrl+Shift on Linux and Windows
  - dot_config/kanata/kanata.kbd — single shared config file; deployed on all platforms
  - dot_local/share/systemd/user/kanata.service — Linux autostart via systemd user service
  - run_once_setup-kanata-linux.sh — Linux group/module/service setup at chezmoi apply time
  - run_once_setup-kanata-windows.ps1 — Windows registry Run key for kanata_gui at chezmoi apply time
  - kanata in Archfile; jtroo.kanata_gui in Wingetfile
key_decisions:
  - D019: single slice
  - D020: Windows autostart via registry Run key (simpler, no admin required)
  - D021: (multi lctl lsft) for simultaneous Ctrl+Shift output
  - D022: systemd service gated Linux-only via .chezmoiignore
patterns_established:
  - run_once PS script Windows guard: $env:OS -ne 'Windows_NT'
  - systemd ExecStart uses %h specifier (not $HOME) for user service home dir
  - kanata.kbd: process-unmapped-keys yes required to pass non-remapped keys through
observability_surfaces:
  - journalctl --user -u kanata -n 50
  - systemctl --user status kanata
  - groups (verify input/uinput membership)
  - lsmod | grep uinput
requirement_outcomes: []
duration: ~45m
verification_result: pass
completed_at: 2026-03-15
---

# M006-mbvfvm: Kanata Cross-Platform Key Remapping

**`chezmoi apply` now deploys a kanata CapsLock → Ctrl+Shift remap to Linux (systemd user service) and Windows (registry Run key via kanata_gui) with zero manual configuration steps after apply.**

## What Happened

Single-slice milestone (S01). All deliverables fit in one pass across 8 files.

**Config:** `dot_config/kanata/kanata.kbd` is a minimal `.kbd` file with `(defcfg process-unmapped-keys yes)`, `(defsrc caps)`, `(deflayer default (multi lctl lsft))`. The `process-unmapped-keys yes` directive is load-bearing — without it kanata would intercept and block all keys not listed in `defsrc`. Deployed to `~/.config/kanata/kanata.kbd` on all platforms by chezmoi.

**Linux:** `dot_local/share/systemd/user/kanata.service` is a systemd user unit with `ExecStart=kanata --cfg %h/.config/kanata/kanata.kbd` (`%h` is the systemd home dir specifier). Gated Linux-only by adding `.local/share/systemd/` to the `ne linux` block in `.chezmoiignore`. The `run_once_setup-kanata-linux.sh` script adds the user to `input`/`uinput` groups, writes `uinput` to `/etc/modules-load.d/uinput.conf`, loads the module immediately, and enables + starts the service. The service will fail on the first apply until the user re-logs in — this is expected behavior and documented in both the service unit description and the script's output.

**Windows:** `run_once_setup-kanata-windows.ps1` locates `kanata_gui.exe` (tries winget packages dir, then PATH, then falls back to bare name), then sets `HKCU:\Software\Microsoft\Windows\CurrentVersion\Run\Kanata` pointing to `"<exe>" --cfg "<USERPROFILE>\.config\kanata\kanata.kbd"`. Registry Run key is fully idempotent — re-running overwrites the same value. The `windows/INSTRUCTION.md` TODO for kanata/komokana migration was removed.

**Install entries:** `kanata` added to `install/Archfile` (alphabetical); `jtroo.kanata_gui` added to `install/Wingetfile`.

## Cross-Slice Verification

| Check | Expected | Actual | Result |
|-------|----------|--------|--------|
| `grep -c 'caps' dot_config/kanata/kanata.kbd` | 1 | 1 | ✓ |
| `grep -c 'multi lctl lsft' dot_config/kanata/kanata.kbd` | 1 | 1 | ✓ |
| `grep 'kanata' install/Archfile` | match | match | ✓ |
| `grep 'kanata_gui' install/Wingetfile` | match | match | ✓ |
| `grep 'ExecStart' dot_local/.../kanata.service` | kanata --cfg %h/... | match | ✓ |
| `grep 'systemd' .chezmoiignore` | .local/share/systemd/ | match | ✓ |
| `chezmoi managed --include=scripts` | lists both kanata scripts | setup-kanata-linux.sh, setup-kanata-windows.ps1 | ✓ |
| `grep -c 'kanata/komokana' windows/INSTRUCTION.md` | 0 | 0 | ✓ |
| `chezmoi apply --dry-run --force` errors | 0 | 0 | ✓ |

## Requirement Changes

No existing REQUIREMENTS.md — new capability milestone. No requirement status transitions.

## Forward Intelligence

### What the next milestone should know
- Adding new key remappings: edit `dot_config/kanata/kanata.kbd`, add new keys to `(defsrc ...)` and `(deflayer default ...)`, run `chezmoi apply` + `systemctl --user restart kanata` on Linux
- The re-login requirement on first Linux apply is expected and documented — not a bug
- macOS: `kanata.kbd` deploys there but is unused; karabiner-elements handles macOS remapping; a future milestone can swap to kanata + karabiner driver when ready
- run_once scripts fire exactly once per machine (keyed on script content hash); if the script needs to change, rename it or clear `chezmoi state delete-bucket --bucket=scriptState`

### What's fragile
- Windows kanata_gui path: the glob search covers common winget install paths but may miss edge cases if Microsoft changes the winget packages directory structure; bare-name fallback is the safety net
- Linux first-apply: kanata service will fail with "Permission denied" until re-login completes group membership; `journalctl --user -u kanata` shows the error clearly

### Authoritative diagnostics
- `journalctl --user -u kanata -n 50` — startup errors, config parse errors, permission denied
- `systemctl --user status kanata` — quick health check
- `groups` — verify `input` and `uinput` present after re-login
- `chezmoi cat ~/.config/kanata/kanata.kbd` — verify deployed config content

## Files Created/Modified

- `dot_config/kanata/kanata.kbd` — kanata config; CapsLock → `(multi lctl lsft)`
- `install/Archfile` — added `kanata`
- `install/Wingetfile` — added `jtroo.kanata_gui`
- `dot_local/share/systemd/user/kanata.service` — systemd user service unit
- `.chezmoiignore` — added `.local/share/systemd/` to Linux-only gate
- `run_once_setup-kanata-linux.sh` — Linux group/module/service setup
- `run_once_setup-kanata-windows.ps1` — Windows registry Run key setup
- `windows/INSTRUCTION.md` — removed kanata/komokana migration TODO
