#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Idempotent Windows developer environment install script.
.DESCRIPTION
    Installs all packages from install/Wingetfile via winget, sets up the mise
    toolchain (Node, Go, ejson), and configures EJSON_KEYDIR.
    Safe to run multiple times -- already-installed packages are skipped.
.NOTES
    Must be run as Administrator.
    Usage: Right-click PowerShell -> Run as Administrator, then:
      .\windows\install.ps1
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"

# --- Admin check (belt-and-suspenders with #Requires above) ---
$identity  = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = [Security.Principal.WindowsPrincipal]$identity
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[FAIL] This script must be run as Administrator." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=== Windows Developer Environment Setup ===" -ForegroundColor Cyan
Write-Host ""

# Track failures across the entire script
$failed = @()

# --- Resolve paths relative to script location ---
$scriptDir  = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot   = Split-Path -Parent $scriptDir
$wingetFile = Join-Path $repoRoot "install\Wingetfile"

if (-not (Test-Path $wingetFile)) {
    Write-Host "[FAIL] Wingetfile not found at: $wingetFile" -ForegroundColor Red
    exit 1
}

# ============================================================
# 1. Winget package installation
# ============================================================
Write-Host "--- Installing winget packages ---" -ForegroundColor Cyan
Write-Host ""

$packages = Get-Content $wingetFile |
    Where-Object { $_ -match '\S' } |
    Where-Object { $_ -notmatch '^\s*#' }

foreach ($packageId in $packages) {
    $packageId = $packageId.Trim()
    if ([string]::IsNullOrWhiteSpace($packageId)) { continue }

    Write-Host "Installing $packageId ..." -ForegroundColor Gray
    $output = winget install -e --id $packageId --no-upgrade --accept-source-agreements --accept-package-agreements 2>&1 | Out-String

    if ($LASTEXITCODE -eq 0) {
        if ($output -match "No applicable update found|already installed") {
            Write-Host "  [OK] $packageId already installed" -ForegroundColor Green
        } else {
            Write-Host "  [OK] $packageId installed" -ForegroundColor Green
        }
    } else {
        # winget returns non-zero for "no applicable update" on some versions
        if ($output -match "No applicable update found|already installed") {
            Write-Host "  [OK] $packageId already installed" -ForegroundColor Green
        } else {
            Write-Host "  [FAIL] $packageId failed (exit code $LASTEXITCODE)" -ForegroundColor Red
            $failed += $packageId
        }
    }
}

Write-Host ""

# ============================================================
# 2. Refresh PATH to pick up newly installed tools
# ============================================================
Write-Host "--- Refreshing PATH ---" -ForegroundColor Cyan
$env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
            [Environment]::GetEnvironmentVariable("Path", "User")
Write-Host "  [OK] PATH refreshed" -ForegroundColor Green
Write-Host ""

# ============================================================
# 3. mise toolchain setup (Node, Go, ejson)
# ============================================================
Write-Host "--- Setting up mise toolchain ---" -ForegroundColor Cyan
Write-Host ""

# Verify mise is available
if (-not (Get-Command mise -ErrorAction SilentlyContinue)) {
    Write-Host "  [FAIL] mise not found in PATH after install" -ForegroundColor Red
    $failed += "mise (not found in PATH)"
} else {
    # Node 24
    Write-Host "  Installing Node 24 via mise ..." -ForegroundColor Gray
    mise use --global node@24 2>&1 | Out-String | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [OK] node@24 configured" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] node@24 setup failed" -ForegroundColor Red
        $failed += "mise node@24"
    }

    # Go latest
    Write-Host "  Installing Go (latest) via mise ..." -ForegroundColor Gray
    mise use --global go@latest 2>&1 | Out-String | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [OK] go@latest configured" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] go@latest setup failed" -ForegroundColor Red
        $failed += "mise go@latest"
    }

    # ejson via go install
    Write-Host "  Installing ejson via go install ..." -ForegroundColor Gray
    mise exec -- go install github.com/Shopify/ejson/cmd/ejson@latest 2>&1 | Out-String | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [OK] ejson installed" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] ejson install failed" -ForegroundColor Red
        $failed += "ejson (go install)"
    }

    # Reshim to create ejson shim
    Write-Host "  Running mise reshim ..." -ForegroundColor Gray
    mise reshim 2>&1 | Out-String | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [OK] mise reshim complete" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] mise reshim failed" -ForegroundColor Red
        $failed += "mise reshim"
    }
}

Write-Host ""

# ============================================================
# 4. EJSON_KEYDIR setup
# ============================================================
Write-Host "--- Configuring EJSON_KEYDIR ---" -ForegroundColor Cyan

$ejsonKeyDir = Join-Path $env:USERPROFILE ".ejson\keys"

# Create directory if it doesn't exist
if (-not (Test-Path $ejsonKeyDir)) {
    New-Item -ItemType Directory -Path $ejsonKeyDir -Force | Out-Null
    Write-Host "  [OK] Created $ejsonKeyDir" -ForegroundColor Green
} else {
    Write-Host "  [OK] $ejsonKeyDir already exists" -ForegroundColor Green
}

# Set at User scope (persists across sessions)
[Environment]::SetEnvironmentVariable("EJSON_KEYDIR", $ejsonKeyDir, "User")
Write-Host "  [OK] EJSON_KEYDIR set at User scope" -ForegroundColor Green

# Set in current session
$env:EJSON_KEYDIR = $ejsonKeyDir
Write-Host "  [OK] EJSON_KEYDIR set in current session: $ejsonKeyDir" -ForegroundColor Green

Write-Host ""

# ============================================================
# 5. Summary
# ============================================================
Write-Host "=== Summary ===" -ForegroundColor Cyan
Write-Host ""

if ($failed.Count -gt 0) {
    Write-Host "The following items failed:" -ForegroundColor Red
    foreach ($item in $failed) {
        Write-Host "  - $item" -ForegroundColor Red
    }
    Write-Host ""
    Write-Host "Re-run this script after resolving the above issues." -ForegroundColor Yellow
    exit 1
} else {
    Write-Host "All packages and tools installed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Installed:" -ForegroundColor Green
    Write-Host "  - $($packages.Count) winget packages" -ForegroundColor Green
    Write-Host "  - Node 24, Go (latest) via mise" -ForegroundColor Green
    Write-Host "  - ejson via go install" -ForegroundColor Green
    Write-Host "  - EJSON_KEYDIR = $ejsonKeyDir" -ForegroundColor Green
    exit 0
}
