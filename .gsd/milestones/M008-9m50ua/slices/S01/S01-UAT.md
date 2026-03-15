# S01: Windows Terminal Settings via Symlink — UAT

## Prerequisites
- Windows machine with `chezmoi apply` run after this slice
- Windows Terminal installed (Store version)
- JetBrainsMono Nerd Font installed (`winget install DEVCOM.JetBrainsMonoNerdFont`)

## Checks

### 1. Symlink exists
Open PowerShell and run:
```powershell
Get-Item "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" | Select-Object LinkType, Target
```
Expected: `LinkType = SymbolicLink`, `Target` pointing to `~\.config\windows-terminal\settings.json`

### 2. Font
Open Windows Terminal. Text should render in JetBrainsMono Nerd Font (monospace, ligatures, nerd font icons visible).

### 3. Color scheme
Terminal background should be dark purple-grey (#282A36 Dracula). Text should be light (#F8F8F2).

### 4. Default profile
New tabs should open in PowerShell 7 (`pwsh`), not Windows PowerShell or cmd.

### 5. Quake mode hotkey
With Windows Terminal running, press `Ctrl+`` (backtick/tilde key). The terminal window should appear/toggle visibility.

### 6. Quake with Russian layout
Switch keyboard to Russian layout. Press `Ctrl+ё` (same physical key). Should toggle the same window.

### 7. Auto-start on login
Reboot the machine. After login, Windows Terminal should be running (check system tray or task manager). Press `Ctrl+`` — quake mode should respond without manually launching WT.

### 8. Tabs visible in summoned window
When the window is summoned via `Ctrl+``, the tab bar should be visible at the top (not hidden by focus mode).
