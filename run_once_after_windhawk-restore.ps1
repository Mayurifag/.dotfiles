# run_once_after_windhawk-restore.ps1
# Restores Windhawk mod settings on a fresh machine.
#
# Triggered automatically by chezmoi apply (run_once_after = runs once per
# unique content hash).
#
# Prerequisites: Windhawk must already be installed (via Wingetfile / winget install).
# If Windhawk is not installed yet this script exits cleanly. NOTE: run_once_after_
# scripts do NOT re-run automatically — to force a re-run after installing Windhawk,
# make a trivial edit to this file (e.g. bump the date below) and run `chezmoi apply`.
# Last-updated: 2026-03-23

if ($env:OS -ne 'Windows_NT') { exit 0 }

$ErrorActionPreference = 'Stop'

$windhawkExe = 'C:\Program Files\Windhawk\windhawk.exe'
$windhawkData = 'C:\ProgramData\Windhawk'
$sourceDir   = Join-Path $env:USERPROFILE '.local\share\chezmoi\windows\windhawk'

# ---------------------------------------------------------------------------
# Guard: Windhawk must be installed
# ---------------------------------------------------------------------------
if (-not (Test-Path $windhawkExe)) {
    Write-Host '[windhawk-restore] Windhawk not installed yet — skipping restore.' -ForegroundColor Yellow
    Write-Host '  Install it first:  winget install --id RamenSoftware.Windhawk --exact --accept-package-agreements'
    exit 0
}

Write-Host '[windhawk-restore] Restoring Windhawk config...' -ForegroundColor Cyan

# ---------------------------------------------------------------------------
# 1. userprofile.json
# ---------------------------------------------------------------------------
$profileSrc = Join-Path $sourceDir 'userprofile.json'
if (Test-Path $profileSrc) {
    # Only restore if the file doesn't already exist (let Windhawk manage its own
    # profile once mods are installed; the file is only needed on a truly fresh machine).
    $profileDst = Join-Path $windhawkData 'userprofile.json'
    if (-not (Test-Path $profileDst)) {
        if (-not (Test-Path $windhawkData)) {
            New-Item -ItemType Directory -Path $windhawkData -Force | Out-Null
        }
        Copy-Item -Path $profileSrc -Destination $profileDst -Force
        Write-Host '  [OK] userprofile.json restored' -ForegroundColor Green
    } else {
        Write-Host '  [SKIP] userprofile.json already present' -ForegroundColor Gray
    }
} else {
    Write-Host "  [WARN] userprofile.json not found in dotfiles: $profileSrc" -ForegroundColor Yellow
}

# ---------------------------------------------------------------------------
# 2. Registry import — mod settings
# ---------------------------------------------------------------------------
$regSrc = Join-Path $sourceDir 'mods-settings.reg'
if (Test-Path $regSrc) {
    Write-Host '  Importing mod settings registry (requires admin)...'
    reg import $regSrc 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host '  [OK] mods-settings.reg imported' -ForegroundColor Green
    } else {
        Write-Host "  [WARN] reg import failed (exit $LASTEXITCODE) — needs admin privileges." -ForegroundColor Yellow
        Write-Host "         Run manually as admin: reg import `"$regSrc`"" -ForegroundColor Yellow
    }
} else {
    Write-Host "  [WARN] mods-settings.reg not found in dotfiles: $regSrc" -ForegroundColor Yellow
}

Write-Host ''
Write-Host '[windhawk-restore] Done. Restart Windhawk for settings to take effect.' -ForegroundColor Green
