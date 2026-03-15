# run_once_setup-kanata-windows.ps1
# Configures kanata_gui keyboard remapper on Windows:
#   - Sets a registry Run key so kanata_gui starts at login
#   - Points kanata_gui at the chezmoi-managed config: ~/.config/kanata/kanata.kbd
#
# This script is idempotent — re-running overwrites the same key value safely.

if ($env:OS -ne 'Windows_NT') { exit 0 }

$ErrorActionPreference = 'Stop'

# Locate kanata_gui.exe — winget installs to a versioned path under LOCALAPPDATA
$kanataExe = $null

# Try winget packages directory first (common install path)
$wingetBase = Join-Path $env:LOCALAPPDATA "Microsoft\WinGet\Packages"
if (Test-Path $wingetBase) {
    $match = Get-ChildItem -Path $wingetBase -Filter "kanata_gui.exe" -Recurse -ErrorAction SilentlyContinue |
             Sort-Object FullName -Descending |
             Select-Object -First 1
    if ($match) { $kanataExe = $match.FullName }
}

# Fall back to PATH resolution (works after winget installs add shim to PATH)
if (-not $kanataExe) {
    $resolved = Get-Command kanata_gui -ErrorAction SilentlyContinue
    if ($resolved) { $kanataExe = $resolved.Source }
}

# Final fallback: just use the name (relies on PATH at login time)
if (-not $kanataExe) {
    $kanataExe = "kanata_gui"
    Write-Host "[kanata] kanata_gui not found in expected paths; using name only — ensure it is on PATH." -ForegroundColor Yellow
}

$configPath = Join-Path $env:USERPROFILE ".config\kanata\kanata.kbd"
$runValue = "`"$kanataExe`" --cfg `"$configPath`""

Write-Host "[kanata] Setting registry Run key: $runValue"
Set-ItemProperty `
    -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" `
    -Name "Kanata" `
    -Value $runValue

Write-Host "[kanata] Done. kanata_gui will start automatically at next login." -ForegroundColor Green
Write-Host "         Config: $configPath"
