# S01 UAT — kanata Cross-Platform Key Remapping

**Slice:** S01 — Ship kanata config, Linux autostart, and Windows autostart
**Milestone:** M006-mbvfvm

> Non-blocking. Test whenever convenient after `chezmoi apply` + kanata install.

---

## Linux UAT

**Prerequisites:** `sudo pacman -S kanata` (or `yay -S kanata`) + `chezmoi apply` + log out/in once.

### Test 1: Service is running

```bash
systemctl --user status kanata
```

Expected: `active (running)` — not `failed` or `inactive`.

### Test 2: Service starts on login

```bash
systemctl --user is-enabled kanata
```

Expected: `enabled`.

### Test 3: CapsLock produces Ctrl+Shift

Open any text input. Press CapsLock. Language should switch (same behavior as pressing Ctrl+Shift directly).

### Test 4: Config change propagates

Add a comment line to `~/.config/kanata/kanata.kbd`, then:

```bash
chezmoi apply
systemctl --user restart kanata
systemctl --user status kanata
```

Expected: service restarts cleanly with the updated config.

### Diagnostics (if tests fail)

```bash
journalctl --user -u kanata -n 50   # startup errors
groups                               # confirm input, uinput present (need re-login if missing)
lsmod | grep uinput                  # confirm uinput module loaded
```

---

## Windows UAT

**Prerequisites:** kanata_gui installed (via `winget install jtroo.kanata_gui`) + `chezmoi apply` + log out/in once.

### Test 1: Registry Run key exists

```powershell
Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "Kanata"
```

Expected: `Kanata` property present with value pointing to `kanata_gui.exe --cfg ...kanata.kbd`.

### Test 2: kanata_gui tray icon visible

After login, a kanata tray icon should appear in the system tray.

### Test 3: CapsLock produces Ctrl+Shift

Open any text input. Press CapsLock. Language should switch.
