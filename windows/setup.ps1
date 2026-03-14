# windows/setup.ps1
# Idempotent setup script for Windows environment

$ErrorActionPreference = "Stop"

Write-Host "--- Starting Windows Environment Setup ---" -ForegroundColor Cyan

# Check for Administrator privileges
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Error: You do not have Administrator rights to run this script!" -ForegroundColor Red
    Write-Host "Please close this window and re-run PowerShell as Administrator." -ForegroundColor Yellow
    exit 1
}

# Set Execution Policy
Write-Host "`n[1/4] Setting Execution Policy..."
$currentPolicy = Get-ExecutionPolicy -Scope CurrentUser
if ($currentPolicy -ne "RemoteSigned") {
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Write-Host "Success: Execution Policy set to RemoteSigned." -ForegroundColor Green
} else {
    Write-Host "Skip: Execution Policy is already RemoteSigned." -ForegroundColor Gray
}

# Enable Developer Mode
Write-Host "`n[2/4] Enabling Developer Mode (required for symlinks)..."
$registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
if (!(Test-Path $registryPath)) {
    New-Item -Path $registryPath -Force | Out-Null
}
New-ItemProperty -Path $registryPath -Name "AllowDevelopmentWithoutDevLicense" -Value 1 -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path $registryPath -Name "AllowAllTrustedApps" -Value 1 -PropertyType DWORD -Force | Out-Null
Write-Host "Success: Developer Mode enabled." -ForegroundColor Green

# Check and Install OpenSSH Client
Write-Host "`n[3/4] Checking OpenSSH Client..."
$sshCapability = Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Client*'
if ($sshCapability.State -ne 'Installed') {
    Write-Host "Installing OpenSSH Client (this may take a minute)..." -ForegroundColor Yellow
    Add-WindowsCapability -Online -Name $sshCapability.Name | Out-Null
    Write-Host "Success: OpenSSH Client installed." -ForegroundColor Green
} else {
    Write-Host "Skip: OpenSSH Client is already installed." -ForegroundColor Gray
}

# Configure SSH Agent Service
Write-Host "`n[4/4] Configuring SSH Agent Service..."
$sshAgent = Get-Service -Name ssh-agent -ErrorAction SilentlyContinue
if ($null -eq $sshAgent) {
    Write-Host "Error: OpenSSH Agent still not found after installation attempt." -ForegroundColor Red
} else {
    if ($sshAgent.StartType -ne "Automatic") {
        Set-Service -Name ssh-agent -StartupType Automatic
        Write-Host "Success: SSH Agent service set to Automatic." -ForegroundColor Green
    }
    if ($sshAgent.Status -ne "Running") {
        Start-Service ssh-agent
        Write-Host "Success: SSH Agent service started." -ForegroundColor Green
    } else {
        Write-Host "Skip: SSH Agent service is already running." -ForegroundColor Gray
    }
}

Write-Host "`n--- Setup Finished ---" -ForegroundColor Cyan
