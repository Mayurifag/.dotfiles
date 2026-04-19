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
Write-Host "`n[1/16] Setting Execution Policy..."
$currentPolicy = Get-ExecutionPolicy -Scope CurrentUser
if ($currentPolicy -ne "RemoteSigned") {
  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
}

# Enable Developer Mode
Write-Host "`n[2/16] Enabling Developer Mode..."
$devRegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
if (!(Test-Path $devRegPath)) { New-Item -Path $devRegPath -Force | Out-Null }
Set-ItemProperty -Path $devRegPath -Name "AllowDevelopmentWithoutDevLicense" -Value 1 -Force
Set-ItemProperty -Path $devRegPath -Name "AllowAllTrustedApps" -Value 1 -Force

# UI Customization (Dark Theme, Taskbar Left, Disable Bing Search)
Write-Host "`n[3/16] Applying UI Preferences (Dark Theme, Taskbar Left, No Bing)..."
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
Write-Host "`n[4/16] Configuring Explorer (Show Hidden, Show Extensions)..."
Set-ItemProperty -Path $advanced -Name "Hidden" -Value 1 -Force
Set-ItemProperty -Path $advanced -Name "HideFileExt" -Value 0 -Force

# Check and Install OpenSSH Client
Write-Host "`n[5/16] Checking OpenSSH Client..."
$sshCapability = Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Client*'
if ($sshCapability.State -ne 'Installed') {
  Add-WindowsCapability -Online -Name $sshCapability.Name | Out-Null
}

# Configure SSH Agent Service
Write-Host "`n[6/16] Configuring SSH Agent Service..."
Set-Service -Name ssh-agent -StartupType Automatic
if ((Get-Service ssh-agent).Status -ne "Running") { Start-Service ssh-agent }

# Enable WSL2
Write-Host "`n[7/16] Enabling WSL2 (VirtualMachinePlatform + Windows Subsystem for Linux)..."
$wslState = (Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux).State
$vmState = (Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform).State
if ($wslState -ne "Enabled") {
  Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart | Out-Null
  Write-Host "  WSL feature enabled (restart required before first use)." -ForegroundColor Yellow
}
else {
  Write-Host "  WSL feature already enabled." -ForegroundColor Green
}
if ($vmState -ne "Enabled") {
  Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart | Out-Null
  Write-Host "  VirtualMachinePlatform enabled (restart required before first use)." -ForegroundColor Yellow
}
else {
  Write-Host "  VirtualMachinePlatform already enabled." -ForegroundColor Green
}
wsl --set-default-version 2 2>&1 | Out-Null
Write-Host "  WSL2 set as default version." -ForegroundColor Green

# Download and Install apps via Winget
Write-Host "`n[8/16] Installing apps via Winget..."
$wingetfileUrl = "https://raw.githubusercontent.com/Mayurifag/.dotfiles/master/install/Wingetfile"
$tempWingetfile = Join-Path $env:TEMP "Wingetfile.txt"
Invoke-RestMethod -Uri $wingetfileUrl -OutFile $tempWingetfile

$apps = Get-Content $tempWingetfile | Where-Object { $_ -match '\S' -and $_ -notmatch '^#' }
foreach ($app in $apps) {
  Write-Host "Installing $app..." -ForegroundColor Yellow
  winget install --id $app.Trim() --exact --accept-package-agreements --accept-source-agreements --silent
}

# Refresh Environment Variables for the current process
Write-Host "`n[9/16] Refreshing environment PATH..."
$env:PATH = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

# Configure mise in PowerShell profile
# Always target the PS7 profile explicitly — using $PROFILE here would write to the
# PS5.1 profile if init.ps1 is invoked via powershell.exe instead of pwsh.exe.
Write-Host "`n[10/16] Configuring mise in PowerShell profile..."
$ps7Profile = "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
$profileDir = Split-Path -Parent $ps7Profile
if (!(Test-Path $profileDir)) { New-Item -ItemType Directory -Path $profileDir -Force | Out-Null }
$miseLine = 'mise activate pwsh | Out-String | Invoke-Expression'
if (!(Test-Path $ps7Profile) -or !(Select-String -Path $ps7Profile -Pattern 'mise activate pwsh' -Quiet)) {
  Add-Content -Path $ps7Profile -Value $miseLine
}

# Ensure make, Git POSIX utils, and Docker are on PATH
Write-Host "`n[11/16] Wiring PATH for make, Git utilities, and Docker..."
$gnuMakeBin = "C:\Program Files (x86)\GnuWin32\bin"
$gitUsrBin = "C:\Program Files\Git\usr\bin"
$gitMingwBin = "C:\Program Files\Git\mingw64\bin"
$miseShims = Join-Path $HOME ".local\share\mise\shims"
$dockerBin = "C:\Program Files\Docker\Docker\resources\bin"

foreach ($dir in @($gnuMakeBin, $gitUsrBin, $gitMingwBin, $miseShims, $dockerBin)) {
  if ((Test-Path $dir) -and ($env:PATH -notlike "*$dir*")) {
    $env:PATH = "$dir;$env:PATH"
  }
}

if (Get-Command make -ErrorAction SilentlyContinue) {
  Write-Host "  make found: $(make --version 2>&1 | Select-Object -First 1)" -ForegroundColor Green
}
else {
  Write-Host "  Warning: make not found on PATH. GnuWin32.Make may not have installed correctly." -ForegroundColor Yellow
  Write-Host "  This is non-blocking — packages will be installed directly." -ForegroundColor Yellow
}

# Bootstrap mise config (chezmoi hasn't run yet — download from GitHub)
Write-Host "`n[12/16] Bootstrapping mise config..."
$miseConfigDir = Join-Path $HOME ".config\mise"
$miseConfigFile = Join-Path $miseConfigDir "config.toml"

if (!(Test-Path $miseConfigFile)) {
  $miseConfigUrl = "https://raw.githubusercontent.com/Mayurifag/.dotfiles/master/dot_config/mise/config.toml.tmpl"
  $rawConfig = Invoke-RestMethod -Uri $miseConfigUrl
  # Strip chezmoi template directives (lines containing {{ }})
  $cleanConfig = ($rawConfig -split "`n" | Where-Object { $_ -notmatch '\{\{' }) -join "`n"

  if (!(Test-Path $miseConfigDir)) {
    New-Item -ItemType Directory -Path $miseConfigDir -Force | Out-Null
  }
  Set-Content -Path $miseConfigFile -Value $cleanConfig -NoNewline
  Write-Host "  Downloaded and cleaned mise config to $miseConfigFile" -ForegroundColor Green
}
else {
  Write-Host "  mise config already exists at $miseConfigFile — skipping" -ForegroundColor Green
}

# Install mise runtimes
Write-Host "`n[13/16] Installing mise runtimes (node, go, python, rust, ruby, uv, bun, chezmoi, ...)..."
Write-Host "  This may take several minutes on first run." -ForegroundColor Yellow
mise install --yes

# Refresh PATH to pick up mise shims
$env:PATH = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
foreach ($dir in @($gnuMakeBin, $gitUsrBin, $gitMingwBin, $miseShims)) {
  if ((Test-Path $dir) -and ($env:PATH -notlike "*$dir*")) {
    $env:PATH = "$dir;$env:PATH"
  }
}

# Install language packages (npm, cargo, go, gem, uv)
Write-Host "`n[14/16] Installing language packages..."
$baseUrl = "https://raw.githubusercontent.com/Mayurifag/.dotfiles/master/install"
$tempDir = Join-Path $env:TEMP "dotfiles-packages"
if (!(Test-Path $tempDir)) { New-Item -ItemType Directory -Path $tempDir -Force | Out-Null }

# Download install files
$installFiles = @("npmfile", "Rustfile", "Gofile", "Rubyfile", "uv-file")
foreach ($file in $installFiles) {
  Invoke-RestMethod -Uri "$baseUrl/$file" -OutFile (Join-Path $tempDir $file)
}

# npm packages
Write-Host "  Installing npm global packages..." -ForegroundColor Yellow
$npmPkgs = (Get-Content (Join-Path $tempDir "npmfile") | Where-Object { $_ -match '\S' -and $_ -notmatch '^#' }) -join " "
if ($npmPkgs) {
  Invoke-Expression "npm install -g $npmPkgs"
}

# Rust packages
Write-Host "  Installing Rust packages (cargo)..." -ForegroundColor Yellow
$rustPkgs = Get-Content (Join-Path $tempDir "Rustfile") | Where-Object { $_ -match '\S' -and $_ -notmatch '^#' }
foreach ($pkg in $rustPkgs) {
  cargo install $pkg.Trim()
}

# Go packages
Write-Host "  Installing Go packages..." -ForegroundColor Yellow
$goPkgs = Get-Content (Join-Path $tempDir "Gofile") | Where-Object { $_ -match '\S' -and $_ -notmatch '^#' }
foreach ($pkg in $goPkgs) {
  go install "$($pkg.Trim())@latest"
}

# Ruby packages
Write-Host "  Installing Ruby gems..." -ForegroundColor Yellow
gem update --system 2>$null
$rubyPkgs = (Get-Content (Join-Path $tempDir "Rubyfile") | Where-Object { $_ -match '\S' -and $_ -notmatch '^#' }) -join " "
if ($rubyPkgs) {
  Invoke-Expression "gem install $rubyPkgs"
}

# uv packages
Write-Host "  Installing uv tools..." -ForegroundColor Yellow
$uvPkgs = Get-Content (Join-Path $tempDir "uv-file") | Where-Object { $_ -match '\S' -and $_ -notmatch '^#' }
foreach ($pkg in $uvPkgs) {
  uv tool install $pkg.Trim()
}

Write-Host "  Language packages installed." -ForegroundColor Green

# Set EJSON_KEYDIR user environment variable (ejson defaults to /opt/ejson/keys on all platforms)
Write-Host "`n[15/16] Setting EJSON_KEYDIR environment variable..."
$ejsonKeyDir = Join-Path $env:USERPROFILE ".ejson\keys"
[System.Environment]::SetEnvironmentVariable("EJSON_KEYDIR", $ejsonKeyDir, "User")
$env:EJSON_KEYDIR = $ejsonKeyDir
Write-Host "  EJSON_KEYDIR set to: $ejsonKeyDir" -ForegroundColor Green

# Post-install instructions
Write-Host "`n[16/16] Setup complete! Manual steps remaining:" -ForegroundColor Cyan
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  NEXT STEPS (do these in order):" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Restart your PC if WSL2 features were just enabled above." -ForegroundColor Yellow
Write-Host "   After restart, Docker Desktop first launch will finish WSL2 backend setup." -ForegroundColor White
Write-Host ""
Write-Host "2. SSH Key (KeePassXC):" -ForegroundColor Yellow
Write-Host "   Open KeePassXC -> Settings -> SSH Agent -> Enable SSH Agent integration." -ForegroundColor White
Write-Host "   Then enable the SSH key entry in your KeePass database for agent use." -ForegroundColor White
Write-Host "   Verify with: ssh-add -l" -ForegroundColor White
Write-Host ""
Write-Host "3. EJSON Keys:" -ForegroundColor Yellow
Write-Host '   New-Item -ItemType Directory -Force "$env:USERPROFILE\.ejson" | Out-Null; cmd /c mklink /D "%USERPROFILE%\.ejson\keys" "D:\OpenCloud\Personal\Software\dotfiles\ejson\keys"' -ForegroundColor White
Write-Host ""
Write-Host "4. Run preflight check (IN A NEW TERMINAL!!!):" -ForegroundColor Yellow
Write-Host '   Invoke-RestMethod -Uri "https://raw.githubusercontent.com/Mayurifag/.dotfiles/master/windows/preflight.ps1" | Invoke-Expression' -ForegroundColor Green
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
