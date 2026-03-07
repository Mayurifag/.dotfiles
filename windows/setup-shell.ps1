<#
.SYNOPSIS
    Deploy dotfiles via chezmoi and create espanso NTFS junction.
.DESCRIPTION
    Runs chezmoi apply to deploy all dotfiles (including .bashrc and
    .bash_profile), creates an NTFS junction from %APPDATA%\espanso to
    ~/.config/espanso so espanso reads chezmoi-deployed config, and
    verifies key files are in place. Idempotent -- safe to re-run.
.NOTES
    Does NOT require Administrator privileges.
    Usage: powershell -ExecutionPolicy Bypass -File windows\setup-shell.ps1
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"

$failCount = 0

Write-Host ""
Write-Host "=== Shell Setup and Dotfiles Deployment ===" -ForegroundColor Cyan
Write-Host ""

# ============================================================
# 1. chezmoi apply
# ============================================================
Write-Host "--- chezmoi apply ---" -ForegroundColor Cyan
Write-Host ""

$chezmoiCmd = Get-Command chezmoi -ErrorAction SilentlyContinue
if (-not $chezmoiCmd) {
    Write-Host "  [FAIL] chezmoi not found in PATH. Install it first (winget install twpayne.chezmoi)." -ForegroundColor Red
    $failCount++
} else {
    Write-Host "  Running chezmoi apply -v ..." -ForegroundColor Gray
    & chezmoi apply -v 2>&1 | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [OK] chezmoi apply completed successfully" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] chezmoi apply exited with code $LASTEXITCODE" -ForegroundColor Red
        $failCount++
    }
}

Write-Host ""

# ============================================================
# 2. Espanso NTFS Junction
# ============================================================
Write-Host "--- Espanso NTFS Junction ---" -ForegroundColor Cyan
Write-Host ""

$espansoTarget = Join-Path $env:USERPROFILE ".config\espanso"
$espansoLink   = Join-Path $env:APPDATA "espanso"

if (-not (Test-Path $espansoTarget)) {
    Write-Host "  [WARN] Target directory does not exist: $espansoTarget" -ForegroundColor Yellow
    Write-Host "  chezmoi may not have deployed espanso config yet." -ForegroundColor Yellow
    Write-Host "  Skipping junction creation." -ForegroundColor Yellow
} elseif (Test-Path $espansoLink) {
    $item = Get-Item $espansoLink -Force
    if ($item.LinkType -eq "Junction") {
        Write-Host "  [OK] Espanso junction already exists: $espansoLink" -ForegroundColor Yellow
    } else {
        Write-Host "  [WARN] $espansoLink exists but is not a junction (type: $($item.GetType().Name))" -ForegroundColor Yellow
        Write-Host "  Not overwriting existing directory. Remove it manually if you want a junction." -ForegroundColor Yellow
    }
} else {
    New-Item -ItemType Junction -Path $espansoLink -Value $espansoTarget | Out-Null
    Write-Host "  [OK] Espanso junction created: $espansoLink -> $espansoTarget" -ForegroundColor Green
}

Write-Host ""

# ============================================================
# 3. Verification
# ============================================================
Write-Host "--- Verification ---" -ForegroundColor Cyan
Write-Host ""

# Check ~/.bashrc
$bashrc = Join-Path $env:USERPROFILE ".bashrc"
if (Test-Path $bashrc) {
    Write-Host "  [OK] ~/.bashrc exists" -ForegroundColor Green
} else {
    Write-Host "  [FAIL] ~/.bashrc not found" -ForegroundColor Red
    $failCount++
}

# Check ~/.bash_profile
$bashProfile = Join-Path $env:USERPROFILE ".bash_profile"
if (Test-Path $bashProfile) {
    Write-Host "  [OK] ~/.bash_profile exists" -ForegroundColor Green
} else {
    Write-Host "  [FAIL] ~/.bash_profile not found" -ForegroundColor Red
    $failCount++
}

# Check ~/.gitconfig
$gitconfig = Join-Path $env:USERPROFILE ".gitconfig"
if (Test-Path $gitconfig) {
    Write-Host "  [OK] ~/.gitconfig exists" -ForegroundColor Green
} else {
    Write-Host "  [FAIL] ~/.gitconfig not found" -ForegroundColor Red
    $failCount++
}

# Check espanso junction
if (Test-Path $espansoLink) {
    $item = Get-Item $espansoLink -Force
    if ($item.LinkType -eq "Junction") {
        Write-Host "  [OK] Espanso junction exists (type: Junction)" -ForegroundColor Green
    } else {
        Write-Host "  [WARN] $espansoLink exists but is not a junction" -ForegroundColor Yellow
    }
} else {
    Write-Host "  [WARN] Espanso junction not found at $espansoLink" -ForegroundColor Yellow
}

Write-Host ""

# ============================================================
# Summary
# ============================================================
if ($failCount -eq 0) {
    Write-Host "=== Setup Complete (all checks passed) ===" -ForegroundColor Green
} else {
    Write-Host "=== Setup Complete ($failCount check(s) failed) ===" -ForegroundColor Yellow
}
Write-Host ""
