#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Idempotent SSH agent setup and GPG/KeePassXC verification script.
.DESCRIPTION
    Enables and starts the Windows OpenSSH agent service, verifies SSH key
    loading from KeePassXC, checks for Gpg4win installation, and prints
    step-by-step instructions for KeePassXC SSH Agent and GPG key import.
    Safe to run multiple times.
.NOTES
    Must be run as Administrator.
    Usage: Right-click PowerShell -> Run as Administrator, then:
      .\windows\setup-ssh-gpg.ps1
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
Write-Host "=== SSH Agent and GPG Setup ===" -ForegroundColor Cyan
Write-Host ""

# ============================================================
# 1. SSH Agent Setup (AUTH-01)
# ============================================================
Write-Host "--- SSH Agent Service ---" -ForegroundColor Cyan
Write-Host ""

$sshAgentService = Get-Service ssh-agent -ErrorAction SilentlyContinue

if (-not $sshAgentService) {
    Write-Host "  [FAIL] ssh-agent service not found. Ensure OpenSSH is installed." -ForegroundColor Red
    exit 1
}

# Set startup type to Automatic (idempotent)
if ($sshAgentService.StartType -ne "Automatic") {
    Set-Service ssh-agent -StartupType Automatic
    Write-Host "  [OK] ssh-agent StartupType set to Automatic" -ForegroundColor Green
} else {
    Write-Host "  [OK] ssh-agent StartupType already Automatic" -ForegroundColor Yellow
}

# Start the service if not running
if ($sshAgentService.Status -ne "Running") {
    Start-Service ssh-agent
    Write-Host "  [OK] ssh-agent service started" -ForegroundColor Green
} else {
    Write-Host "  [OK] ssh-agent service already running" -ForegroundColor Yellow
}

# Print current status
$sshAgentService = Get-Service ssh-agent
Write-Host ""
Write-Host "  Service Status:" -ForegroundColor Gray
Write-Host "    Status:    $($sshAgentService.Status)" -ForegroundColor Gray
Write-Host "    StartType: $($sshAgentService.StartType)" -ForegroundColor Gray
Write-Host ""

# ============================================================
# 2. SSH Key Verification
# ============================================================
Write-Host "--- SSH Key Verification ---" -ForegroundColor Cyan
Write-Host ""

$sshAddPath = "C:\Windows\System32\OpenSSH\ssh-add.exe"
if (Test-Path $sshAddPath) {
    $keyOutput = & $sshAddPath -l 2>&1 | Out-String
    if ($LASTEXITCODE -eq 0 -and $keyOutput -notmatch "no identities") {
        Write-Host "  [OK] SSH keys loaded in agent:" -ForegroundColor Green
        Write-Host "  $($keyOutput.Trim())" -ForegroundColor Gray
    } else {
        Write-Host "  [WARN] No SSH keys loaded in agent." -ForegroundColor Yellow
        Write-Host "  Configure KeePassXC to share your SSH key (see instructions below)." -ForegroundColor Yellow
    }
} else {
    Write-Host "  [FAIL] ssh-add.exe not found at $sshAddPath" -ForegroundColor Red
}

Write-Host ""

# ============================================================
# 3. KeePassXC SSH Agent Instructions (AUTH-02)
# ============================================================
Write-Host "--- KeePassXC SSH Agent Setup ---" -ForegroundColor Cyan
Write-Host ""
Write-Host "  === KeePassXC SSH Agent Setup ===" -ForegroundColor Cyan
Write-Host "  1. Open KeePassXC" -ForegroundColor White
Write-Host "  2. Tools > Settings > SSH Agent" -ForegroundColor White
Write-Host "  3. Check 'Enable SSH Agent integration'" -ForegroundColor White
Write-Host "  4. Check 'Use OpenSSH for Windows instead of Pageant'" -ForegroundColor White
Write-Host "  5. Click OK" -ForegroundColor White
Write-Host "  6. Right-click your SSH key entry > SSH Agent > Add key to agent" -ForegroundColor White
Write-Host "  7. Verify:" -ForegroundColor White
Write-Host "     & `"C:\Windows\System32\OpenSSH\ssh-add.exe`" -l" -ForegroundColor Gray
Write-Host "     (should show your key)" -ForegroundColor Gray
Write-Host ""

# ============================================================
# 4. Gpg4win Verification (AUTH-03)
# ============================================================
Write-Host "--- Gpg4win Verification ---" -ForegroundColor Cyan
Write-Host ""

$gpgPathX86 = "C:\Program Files (x86)\GnuPG\bin\gpg.exe"
$gpgPath64  = "C:\Program Files\GnuPG\bin\gpg.exe"
$gpgFound   = $null

if (Test-Path $gpgPathX86) {
    $gpgFound = $gpgPathX86
} elseif (Test-Path $gpgPath64) {
    $gpgFound = $gpgPath64
}

if ($gpgFound) {
    Write-Host "  [OK] Gpg4win found at: $gpgFound" -ForegroundColor Green
    $gpgVersion = & $gpgFound --version 2>&1 | Select-Object -First 1
    Write-Host "  $gpgVersion" -ForegroundColor Gray
} else {
    Write-Host "  [WARN] Gpg4win not found." -ForegroundColor Yellow
    Write-Host "  Run windows\install.ps1 first to install Gpg4win via winget." -ForegroundColor Yellow
}

Write-Host ""

# ============================================================
# 5. GPG Key Import Instructions (AUTH-03)
# ============================================================
Write-Host "--- GPG Key Import ---" -ForegroundColor Cyan
Write-Host ""
Write-Host "  === GPG Key Import ===" -ForegroundColor Cyan
Write-Host "  1. Import your private key:" -ForegroundColor White
Write-Host "     gpg --import path/to/private-key.asc" -ForegroundColor Gray
Write-Host "  2. Verify key imported:" -ForegroundColor White
Write-Host "     gpg --list-secret-keys --keyid-format long" -ForegroundColor Gray
Write-Host "     (Should show key ID 871672CCF33EDE72)" -ForegroundColor Gray
Write-Host "  3. Trust the key:" -ForegroundColor White
Write-Host "     gpg --edit-key 871672CCF33EDE72" -ForegroundColor Gray
Write-Host "     At gpg> prompt: type 'trust', select 5 (ultimate), type 'quit'" -ForegroundColor Gray
Write-Host ""

# ============================================================
# 6. Verification Checklist
# ============================================================
Write-Host "--- Verify Everything Works ---" -ForegroundColor Cyan
Write-Host ""
Write-Host "  === Verification Checklist ===" -ForegroundColor Cyan
Write-Host "  [ ] Get-Service ssh-agent                           # Status: Running" -ForegroundColor White
Write-Host "  [ ] & `"C:\Windows\System32\OpenSSH\ssh-add.exe`" -l  # Shows your key" -ForegroundColor White
Write-Host "  [ ] ssh -T git@github.com                           # 'Hi Mayurifag!'" -ForegroundColor White
Write-Host "  [ ] gpg --list-secret-keys --keyid-format long      # Shows key" -ForegroundColor White
Write-Host "  [ ] git commit --allow-empty -m 'test gpg' && git log --show-signature -1" -ForegroundColor White
Write-Host ""

Write-Host "=== Setup Complete ===" -ForegroundColor Cyan
Write-Host ""
