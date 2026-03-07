<#
.SYNOPSIS
    Set Windows 11 system preferences via registry.
.DESCRIPTION
    Configures essential Windows 11 developer preferences: dark mode, file
    extensions visible, hidden files shown, taskbar left-aligned. Parallels
    the macOS defaults.sh script for cross-platform dotfiles parity.

    All changes use HKCU (current user) registry hive -- no admin required.
    Explorer is restarted to apply changes immediately.

    This script is idempotent -- safe to re-run.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"

Write-Host "Windows Defaults" -ForegroundColor Cyan
Write-Host "================" -ForegroundColor Cyan
Write-Host ""

# ---------------------------------------------------------------------------
# Personalization: Dark Mode
# ---------------------------------------------------------------------------
$personalizePath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"

Set-ItemProperty -Path $personalizePath -Name "AppsUseLightTheme" -Value 0 -Type DWord -Force
Write-Host "[OK]   " -ForegroundColor Green -NoNewline
Write-Host "Dark mode enabled for apps"

Set-ItemProperty -Path $personalizePath -Name "SystemUsesLightTheme" -Value 0 -Type DWord -Force
Write-Host "[OK]   " -ForegroundColor Green -NoNewline
Write-Host "Dark mode enabled for system"

# ---------------------------------------------------------------------------
# Explorer: File Extensions, Hidden Files, Taskbar
# ---------------------------------------------------------------------------
$explorerPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"

Set-ItemProperty -Path $explorerPath -Name "HideFileExt" -Value 0 -Type DWord -Force
Write-Host "[OK]   " -ForegroundColor Green -NoNewline
Write-Host "File extensions visible in Explorer"

Set-ItemProperty -Path $explorerPath -Name "Hidden" -Value 1 -Type DWord -Force
Write-Host "[OK]   " -ForegroundColor Green -NoNewline
Write-Host "Hidden files shown in Explorer"

Set-ItemProperty -Path $explorerPath -Name "TaskbarAl" -Value 0 -Type DWord -Force
Write-Host "[OK]   " -ForegroundColor Green -NoNewline
Write-Host "Taskbar aligned to left"

# ---------------------------------------------------------------------------
# Restart Explorer to apply changes
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "Restarting Explorer to apply changes..." -ForegroundColor Yellow
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
# Explorer auto-restarts after being stopped
Start-Sleep -Seconds 2
Write-Host "[OK]   " -ForegroundColor Green -NoNewline
Write-Host "Explorer restarted"

Write-Host ""
Write-Host "Done! All Windows defaults applied." -ForegroundColor Cyan
