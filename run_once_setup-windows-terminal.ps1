# run_once_setup-windows-terminal.ps1
# Symlinks Windows Terminal's settings.json directly to the chezmoi source at
# ~/.local/share/chezmoi/dot_config/windows-terminal/settings.json so that WT
# reads/writes the dotfiles repo copy in-place.
#
# Requires Developer Mode enabled (init.ps1 step 2 does this).
# Idempotent — skips if the symlink already points to the correct target.

if ($env:OS -ne 'Windows_NT') { exit 0 }

$ErrorActionPreference = 'Stop'

$source = Join-Path $env:USERPROFILE ".local\share\chezmoi\dot_config\windows-terminal\settings.json"
$wtLocalState = Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
$target = Join-Path $wtLocalState "settings.json"

# Verify source file exists in chezmoi source dir
if (-not (Test-Path $source)) {
    Write-Host "[wt] ERROR: Source file not found: $source" -ForegroundColor Red
    exit 1
}

# Verify WT LocalState directory exists (WT must have been launched at least once)
if (-not (Test-Path $wtLocalState)) {
    Write-Host "[wt] WARNING: Windows Terminal LocalState directory not found." -ForegroundColor Yellow
    Write-Host "     Launch Windows Terminal once, close it, then re-run 'chezmoi apply'." -ForegroundColor Yellow
    Write-Host "     Expected: $wtLocalState" -ForegroundColor Yellow
    exit 0
}

# Check Developer Mode (required for file symlinks without admin)
$devMode = $false
try {
    $regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
    $val = Get-ItemProperty -Path $regPath -Name "AllowDevelopmentWithoutDevLicense" -ErrorAction SilentlyContinue
    if ($val -and $val.AllowDevelopmentWithoutDevLicense -eq 1) { $devMode = $true }
} catch {}

if (-not $devMode) {
    Write-Host "[wt] ERROR: Developer Mode is not enabled." -ForegroundColor Red
    Write-Host "     File symlinks require Developer Mode. Run init.ps1 or enable in:" -ForegroundColor Red
    Write-Host "     Settings > System > For developers > Developer Mode" -ForegroundColor Red
    exit 1
}

# If target is already a symlink pointing to source, nothing to do
if (Test-Path $target) {
    $item = Get-Item $target -Force
    if ($item.LinkType -eq 'SymbolicLink' -and $item.Target -contains $source) {
        Write-Host "[wt] Symlink already correct: $target -> $source" -ForegroundColor Green
        exit 0
    }

    # Back up existing settings.json
    $backup = Join-Path $wtLocalState "settings.json.bak"
    Write-Host "[wt] Backing up existing settings.json to settings.json.bak"
    Copy-Item -Path $target -Destination $backup -Force
    Remove-Item -Path $target -Force
}

# Create symlink
Write-Host "[wt] Creating symlink: $target -> $source"
cmd /c mklink "$target" "$source" | Out-Null

if (Test-Path $target) {
    Write-Host "[wt] Done. Windows Terminal will use chezmoi-managed settings." -ForegroundColor Green
    Write-Host "     Source: $source"
    Write-Host "     Target: $target"
} else {
    Write-Host "[wt] ERROR: Symlink creation failed." -ForegroundColor Red
    Write-Host "     Try running: cmd /c mklink `"$target`" `"$source`"" -ForegroundColor Red
    exit 1
}
