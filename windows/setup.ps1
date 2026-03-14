# windows/setup.ps1
# Idempotent setup script for Windows environment

$ErrorActionPreference = "Stop"

Write-Host "--- Starting Windows Environment Setup ---" -ForegroundColor Cyan

# Set Execution Policy
Write-Host "Setting Execution Policy..."
$currentPolicy = Get-ExecutionPolicy -Scope CurrentUser
if ($currentPolicy -ne "RemoteSigned") {
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Write-Host "Success: Execution Policy set to RemoteSigned." -ForegroundColor Green
} else {
    Write-Host "Skip: Execution Policy is already RemoteSigned." -ForegroundColor Gray
}

# Configure SSH Agent Service
Write-Host "Configuring SSH Agent Service..."
$sshAgent = Get-Service -Name ssh-agent -ErrorAction SilentlyContinue
if ($null -eq $sshAgent) {
    Write-Host "Error: OpenSSH Agent not found. Please install OpenSSH Client via Windows Features." -ForegroundColor Red
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

Write-Host "--- Setup Finished ---" -ForegroundColor Cyan
