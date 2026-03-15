# M006-mbvfvm: Kanata Cross-Platform Key Remapping

**Vision:** Add kanata keyboard remapping to the dotfiles so that CapsLock sends `Ctrl+Shift` (language switch) on Linux and Windows automatically after `chezmoi apply`, with no manual install or configuration steps. A single `.kbd` config file is the authoritative key mapping definition; the chezmoi-managed systemd service (Linux) and registry Run key (Windows) ensure kanata starts on login.

## Success Criteria

- CapsLock sends Ctrl+Shift on Linux: `systemctl --user status kanata` shows active/running; pressing CapsLock produces Ctrl+Shift
- `systemctl --user is-enabled kanata` returns `enabled` (starts on login automatically on Linux)
- On Windows: after `chezmoi apply`, `kanata_gui` starts at login via registry Run key; pressing CapsLock produces Ctrl+Shift
- `chezmoi apply --dry-run --force` produces zero errors
- Adding a new remap to `kanata.kbd` and running `chezmoi apply` + `systemctl --user restart kanata` applies it on Linux without any manual file copying

## Key Risks / Unknowns

- **Linux uinput group membership** — kanata requires the user to be in `input` and `uinput` groups; `usermod` in run_once takes effect only after re-login; the service will fail on first apply until then — expected behavior, must be documented clearly
- **Linux uinput module availability** — `uinput` module may not be auto-loaded on all Arch installs; the run_once script should add a `modules-load.d` entry as a safety net

## Proof Strategy

- Linux group membership risk → retire in S01 by shipping the run_once script that adds the user to both groups, enabling the service, and documenting the re-login requirement in the service unit description

## Verification Classes

- Contract verification: `chezmoi apply --dry-run --force` zero errors; `grep`/`cat` checks on deployed files; `systemctl --user status kanata` on Linux
- Integration verification: `systemctl --user start kanata` succeeds on Linux; kanata process running; CapsLock produces Ctrl+Shift (manual key test on Linux)
- Operational verification: `systemctl --user is-enabled kanata` returns `enabled`; after login, kanata is active without manual start; Windows registry Run key present and pointing to correct path
- UAT / human verification: manual key press test on Windows (cannot automate cross-platform)

## Milestone Definition of Done

This milestone is complete only when all are true:

- `dot_config/kanata/kanata.kbd` tracked by chezmoi with CapsLock → Ctrl+Shift remap
- `kanata` appears in `install/Archfile`
- `jtroo.kanata_gui` appears in `install/Wingetfile`
- `dot_local/share/systemd/user/kanata.service` tracked by chezmoi; Linux-only deployment gated in `.chezmoiignore`
- `run_once_setup-kanata-linux.sh` tracked by chezmoi; adds user to groups, loads uinput module, enables + starts service
- `run_once_setup-kanata-windows.ps1` tracked by chezmoi; sets registry Run key for kanata_gui with `--cfg` pointing to `~/.config/kanata/kanata.kbd`
- `windows/INSTRUCTION.md` TODO for kanata/komokana removed
- `chezmoi apply --dry-run --force` produces zero errors
- On Linux: `systemctl --user status kanata` shows active and `is-enabled` returns enabled (after re-login from group add)

## Requirement Coverage

- Covers: new capability (cross-platform key remapping via kanata)
- Partially covers: none
- Leaves for later: macOS kanata (karabiner-elements stays for now); additional key remappings beyond CapsLock
- Orphan risks: none

## Slices

- [x] **S01: Ship kanata config, Linux autostart, and Windows autostart** `risk:low` `depends:[]`
  > After this: `chezmoi apply` on Linux deploys kanata.kbd + systemd service; `systemctl --user enable --now kanata` works (after re-login for group membership); `chezmoi apply` on Windows sets the registry Run key for kanata_gui; CapsLock → Ctrl+Shift on both platforms.

## Boundary Map

### S01 (leaf — no upstream dependencies)

Produces:
- `~/.config/kanata/kanata.kbd` — CapsLock → `(multi lctl lsft)` remap; single file deployed on all platforms by chezmoi
- `~/.local/share/systemd/user/kanata.service` — systemd user service unit; Linux-only (gated in `.chezmoiignore`)
- run_once Linux side-effect: user added to `input`/`uinput` groups; `uinput` in `/etc/modules-load.d/`; service enabled + started
- run_once Windows side-effect: `HKCU:\Software\Microsoft\Windows\CurrentVersion\Run` entry `Kanata` pointing to `kanata_gui.exe --cfg %USERPROFILE%\.config\kanata\kanata.kbd`

Consumes:
- nothing (first and only slice)

---

# S01: Ship kanata config, Linux autostart, and Windows autostart

**Goal:** Deploy a working kanata setup via chezmoi that remaps CapsLock → Ctrl+Shift on Linux (systemd user service) and Windows (registry Run key), with all required install entries in Archfile and Wingetfile.
**Demo:** On Linux after `chezmoi apply` + re-login (for group membership): `systemctl --user status kanata` shows active; pressing CapsLock produces Ctrl+Shift. On Windows after `chezmoi apply`: registry Run key exists; kanata_gui starts at next login and CapsLock sends Ctrl+Shift.

## Must-Haves

- `dot_config/kanata/kanata.kbd` exists with `(defsrc caps)` and `(deflayer default (multi lctl lsft))`
- `kanata` in `install/Archfile`
- `jtroo.kanata_gui` in `install/Wingetfile`
- `dot_local/share/systemd/user/kanata.service` exists; Linux-only via `.chezmoiignore`
- `run_once_setup-kanata-linux.sh` exists; idempotent; adds groups, loads uinput module, enables + starts service; Linux guard via `uname -s`
- `run_once_setup-kanata-windows.ps1` exists; idempotent; sets `HKCU:\...\Run` registry key; Windows-detectable guard
- `windows/INSTRUCTION.md` no longer contains `kanata/komokana` TODO line
- `chezmoi apply --dry-run --force` produces zero errors

## Proof Level

- This slice proves: integration (Linux), contract (Windows — registry key present but live test requires Windows)
- Real runtime required: yes (Linux systemd service must start successfully)
- Human/UAT required: yes (Windows live key press test)

## Verification

- `grep -c 'caps' dot_config/kanata/kanata.kbd` → 1
- `grep -c 'lctl.*lsft\|multi lctl lsft' dot_config/kanata/kanata.kbd` → 1
- `grep 'kanata' install/Archfile` → matches
- `grep 'kanata_gui' install/Wingetfile` → matches
- `cat dot_local/share/systemd/user/kanata.service` → shows valid unit with ExecStart pointing to kanata + cfg path
- `chezmoi apply --dry-run --force 2>&1 | grep -i error | grep -v 'ejson\|decrypt' | wc -l` → 0
- On Linux after `chezmoi apply`: `systemctl --user status kanata` → active; `systemctl --user is-enabled kanata` → enabled

## Observability / Diagnostics

- Runtime signals: `journalctl --user -u kanata` — startup errors, config parse errors, permission denied (uinput/input group)
- Inspection surfaces: `systemctl --user status kanata`; `groups` (verify input/uinput membership after re-login); `lsmod | grep uinput`
- Failure visibility: "Permission denied" in kanata logs = group membership not yet active (re-login required); "No such file" = kanata binary not installed yet
- Redaction constraints: none

## Integration Closure

- Upstream surfaces consumed: none (leaf slice)
- New wiring introduced: chezmoi source → `~/.config/kanata/kanata.kbd`; chezmoi source → `~/.local/share/systemd/user/kanata.service`; run_once scripts execute on `chezmoi apply`
- What remains before the milestone is truly usable end-to-end: re-login on Linux after first apply (group membership); kanata install via `sudo pacman -S kanata` or Archfile on fresh machine; Windows live test

## Tasks

- [ ] **T01: Write kanata.kbd config and add install entries** `est:15m`
  - Why: the config file and install list entries are the core deliverable — everything else wires to them
  - Files: `dot_config/kanata/kanata.kbd`, `install/Archfile`, `install/Wingetfile`
  - Do: Create `dot_config/kanata/kanata.kbd` with `(defcfg process-unmapped-keys yes)`, `(defsrc caps)`, `(deflayer default (multi lctl lsft))`. Add `kanata` to `install/Archfile` (alphabetical order). Add `jtroo.kanata_gui` to `install/Wingetfile` (alphabetical order). Keep the .kbd file minimal — only remap caps, nothing else.
  - Verify: `grep -c 'caps' dot_config/kanata/kanata.kbd` → 1; `grep 'kanata' install/Archfile` matches; `grep 'kanata_gui' install/Wingetfile` matches
  - Done when: kanata.kbd syntactically valid (can be dry-tested with `kanata --check --cfg` if kanata is installed locally); Archfile and Wingetfile contain correct entries

- [ ] **T02: Write systemd user service unit and gate it Linux-only** `est:15m`
  - Why: kanata on Linux is managed as a systemd user service; the unit must live in `~/.local/share/systemd/user/` and only deploy on Linux
  - Files: `dot_local/share/systemd/user/kanata.service`, `.chezmoiignore`
  - Do: Create `dot_local/share/systemd/user/kanata.service` — Description explains the re-login requirement for group membership, ExecStart uses `kanata --cfg %h/.config/kanata/kanata.kbd` (`%h` = home dir in systemd unit syntax), Restart=no (don't restart on crash — config errors should be visible), WantedBy=default.target. Add Linux-only gate to `.chezmoiignore`: `{{- if ne .chezmoi.os "linux" }}\n.local/share/systemd/\n{{- end }}`. Verify this pattern matches the existing `.chezmoiignore` gating style.
  - Verify: `cat dot_local/share/systemd/user/kanata.service` shows valid unit; `grep 'systemd' .chezmoiignore` confirms gate present; `chezmoi apply --dry-run --force 2>&1 | grep -i error | grep -v 'ejson\|decrypt'` → empty
  - Done when: service file present with correct ExecStart; chezmoiignore gate prevents deployment on non-Linux

- [ ] **T03: Write Linux run_once setup script** `est:20m`
  - Why: kanata requires `input`/`uinput` group membership and the `uinput` kernel module to be loaded; these must be configured idempotently at `chezmoi apply` time
  - Files: `run_once_setup-kanata-linux.sh`
  - Do: Create executable `run_once_setup-kanata-linux.sh`. Guard with `[ "$(uname -s)" = "Linux" ] || exit 0`. Steps: (1) add user to `input` group with `sudo usermod -aG input "$USER"` (idempotent — usermod does nothing if already member); (2) add user to `uinput` group with `sudo usermod -aG uinput "$USER"`; (3) create `/etc/modules-load.d/uinput.conf` containing `uinput` to ensure module loads on boot — use `echo 'uinput' | sudo tee /etc/modules-load.d/uinput.conf > /dev/null`; (4) load uinput now with `sudo modprobe uinput 2>/dev/null || true` (ignore if already loaded); (5) `systemctl --user daemon-reload`; (6) `systemctl --user enable kanata.service`; (7) `systemctl --user start kanata.service` (will likely fail first run due to group — that's ok, just print a note); (8) echo "NOTE: Log out and log back in for group changes to take effect, then run: systemctl --user start kanata". Make script executable (`chmod +x`) in repo.
  - Verify: `ls -la run_once_setup-kanata-linux.sh` shows executable bit; `head -3 run_once_setup-kanata-linux.sh` shows Linux guard; `grep 'usermod' run_once_setup-kanata-linux.sh` → both groups; `chezmoi managed --include=scripts` → lists the script after apply
  - Done when: script is executable, Linux-guarded, idempotent group adds, uinput module setup, service enable + start, clear re-login note

- [ ] **T04: Write Windows run_once setup script and clean INSTRUCTION.md** `est:15m`
  - Why: kanata_gui needs to start at login on Windows; registry Run key is the simplest mechanism; INSTRUCTION.md has a stale TODO to remove
  - Files: `run_once_setup-kanata-windows.ps1`, `windows/INSTRUCTION.md`
  - Do: Create `run_once_setup-kanata-windows.ps1`. Guard with `if ($env:OS -ne 'Windows_NT') { exit 0 }`. Locate kanata_gui.exe: try known winget install paths (`$env:LOCALAPPDATA\Microsoft\WinGet\Packages\jtroo.kanata_gui*\kanata_gui.exe` glob, or `$env:ProgramFiles\kanata_gui\kanata_gui.exe`); if not found, use just `kanata_gui` (relies on PATH after winget install). Set registry key: `Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "Kanata" -Value "`"$kanataExe`" --cfg `"$env:USERPROFILE\.config\kanata\kanata.kbd`""`. This is idempotent — overwriting the same key value is safe. Remove the `- [ ] Migrate to kanata/komokana` TODO line from `windows/INSTRUCTION.md`.
  - Verify: `head -5 run_once_setup-kanata-windows.ps1` shows Windows guard; `grep 'CurrentVersion\\Run' run_once_setup-kanata-windows.ps1` matches; `grep -c 'kanata/komokana' windows/INSTRUCTION.md` → 0; `chezmoi apply --dry-run --force 2>&1 | grep -i error | grep -v 'ejson\|decrypt'` → empty
  - Done when: PS script executable, Windows-guarded, sets registry Run key idempotently with correct path; INSTRUCTION.md no longer contains kanata TODO

- [ ] **T05: Final verification and STATE.md** `est:10m`
  - Why: confirm all pieces are wired together and the milestone is ready to mark done
  - Files: `.gsd/STATE.md`, `.gsd/DECISIONS.md`
  - Do: Run `chezmoi apply --dry-run --force 2>&1 | grep -i error | grep -v 'ejson\|decrypt'` — must be empty. Run `chezmoi managed --include=scripts` — confirm both run_once scripts are tracked. Verify `chezmoi cat ~/.config/kanata/kanata.kbd` renders the config correctly. Check `chezmoi cat ~/.local/share/systemd/user/kanata.service` renders (Linux). Append new decisions (D019–D022) to `.gsd/DECISIONS.md`. Create `.gsd/STATE.md` with milestone complete status.
  - Verify: all grep checks from T01–T04 pass; `chezmoi apply --dry-run --force` zero errors; git log shows clean commits on slice branch
  - Done when: zero dry-run errors; all files present and correctly deployed; DECISIONS.md updated; STATE.md reflects milestone completion

## Files Likely Touched

- `dot_config/kanata/kanata.kbd`
- `install/Archfile`
- `install/Wingetfile`
- `dot_local/share/systemd/user/kanata.service`
- `.chezmoiignore`
- `run_once_setup-kanata-linux.sh`
- `run_once_setup-kanata-windows.ps1`
- `windows/INSTRUCTION.md`
- `.gsd/DECISIONS.md`
- `.gsd/STATE.md`
