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
Write-Host "`n[1/10] Setting Execution Policy..."
$currentPolicy = Get-ExecutionPolicy -Scope CurrentUser
if ($currentPolicy -ne "RemoteSigned") {
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
}

# Enable Developer Mode
Write-Host "`n[2/10] Enabling Developer Mode..."
$devRegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
if (!(Test-Path $devRegPath)) { New-Item -Path $devRegPath -Force | Out-Null }
Set-ItemProperty -Path $devRegPath -Name "AllowDevelopmentWithoutDevLicense" -Value 1 -Force
Set-ItemProperty -Path $devRegPath -Name "AllowAllTrustedApps" -Value 1 -Force

# UI Customization (Dark Theme, Taskbar Left, Disable Bing Search)
Write-Host "`n[3/10] Applying UI Preferences (Dark Theme, Taskbar Left, No Bing)..."
$personalize = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
Set-ItemProperty -Path $personalize -Name "AppsUseLightTheme" -Value 0 -Force
Set-ItemProperty -Path $personalize -Name "SystemUsesLightTheme" -Value 0 -Force

$advanced = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
Set-ItemProperty -Path $advanced -Name "TaskbarAl" -Value 0 -Force # Left alignment

$search = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"
if (!(Test-Path $search)) { New-Item -Path $search -Force | Out-Null }
Set-ItemProperty -Path $search -Name "BingSearchEnabled" -Value 0 -Force
Set-ItemProperty -Path $search -Name "CortanaConsent" -Value 0 -Force

# Explorer Preferences
Write-Host "`n[4/10] Configuring Explorer (Show Hidden, Show Extensions)..."
Set-ItemProperty -Path $advanced -Name "Hidden" -Value 1 -Force
Set-ItemProperty -Path $advanced -Name "HideFileExt" -Value 0 -Force

# Check and Install OpenSSH Client
Write-Host "`n[5/10] Checking OpenSSH Client..."
$sshCapability = Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Client*'
if ($sshCapability.State -ne 'Installed') {
    Add-WindowsCapability -Online -Name $sshCapability.Name | Out-Null
}

# Configure SSH Agent Service
Write-Host "`n[6/10] Configuring SSH Agent Service..."
Set-Service -Name ssh-agent -StartupType Automatic
if ((Get-Service ssh-agent).Status -ne "Running") { Start-Service ssh-agent }

# Download and Install apps via Winget
Write-Host "`n[7/10] Installing apps via Winget..."
$wingetfileUrl = "https://raw.githubusercontent.com/Mayurifag/.dotfiles/main/install/Wingetfile"
$tempWingetfile = Join-Path $env:TEMP "Wingetfile.txt"
Invoke-RestMethod -Uri $wingetfileUrl -OutFile $tempWingetfile

$apps = Get-Content $tempWingetfile | Where-Object { $_ -match '\S' -and $_ -notmatch '^#' }
foreach ($app in $apps) {
    Write-Host "Installing $app..." -ForegroundColor Yellow
    winget install --id $app.Trim() --exact --accept-package-agreements --accept-source-agreements --upgrade --silent
}

# Refresh Environment Variables for the current process
Write-Host "`n[8/10] Refreshing environment PATH..."
$env:PATH = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

# Configure mise in PowerShell profile
Write-Host "`n[9/10] Configuring mise in PowerShell profile..."
$profileDir = Split-Path -Parent $PROFILE
if (!(Test-Path $profileDir)) { New-Item -ItemType Directory -Path $profileDir -Force | Out-Null }
$miseLine = 'Invoke-Expression (mise activate powershell)'
if (!(Test-Path $PROFILE) -or !(Select-String -Path $PROFILE -Pattern 'mise activate powershell' -Quiet)) {
    Add-Content -Path $PROFILE -Value $miseLine
}

# Install Mise Packages
Write-Host "`n[10/10] Installing language packages via Mise..."
if (Get-Command mise -ErrorAction SilentlyContinue) {
    # We must trust the local config to allow automatic installation
    mise trust
    mise install -y

    # Function to install global packages
    function Install-PackageList($file, $execCmd) {
        $path = Join-Path (Get-Location) "install/$file"
        if (Test-Path $path) {
            Get-Content $path | Where-Object { $_ -match '\S' } | ForEach-Object {
                Write-Host "Installing $_ via $execCmd..." -ForegroundColor Gray
                Invoke-Expression "$execCmd $_"
            }
        }
    }

    # Install packages defined in dotfiles
    Install-PackageList "npmfile" "npm install -g"
    Install-PackageList "Rustfile" "cargo install"
    Install-PackageList "uv-file" "uv tool install"
} else {
    Write-Host "Warning: mise not found in PATH. You may need to run 'mise install' after restarting." -ForegroundColor Red
}

Write-Host "`n--- Setup Finished. Please restart your terminal. ---" -ForegroundColor Cyan
