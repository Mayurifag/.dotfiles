# run_after_windhawk-backup.ps1
# Exports the current Windhawk state back into the dotfiles repo on every chezmoi apply.
# Keeps windows/windhawk/userprofile.json and mods-settings.reg in sync automatically.

if ($env:OS -ne 'Windows_NT') { exit 0 }

$windhawkExe  = 'C:\Program Files\Windhawk\windhawk.exe'
$windhawkData = 'C:\ProgramData\Windhawk'
$destDir      = Join-Path $env:USERPROFILE '.local\share\chezmoi\windows\windhawk'

if (-not (Test-Path $windhawkExe)) {
    Write-Host '[windhawk-backup] Windhawk not installed — skipping backup.' -ForegroundColor Yellow
    exit 0
}

Write-Host '[windhawk-backup] Backing up Windhawk config to dotfiles...' -ForegroundColor Cyan

# 1. userprofile.json
$profileSrc = Join-Path $windhawkData 'userprofile.json'
if (Test-Path $profileSrc) {
    Copy-Item -Path $profileSrc -Destination (Join-Path $destDir 'userprofile.json') -Force
    Write-Host '  [OK] userprofile.json' -ForegroundColor Green
} else {
    Write-Host '  [SKIP] userprofile.json not found' -ForegroundColor Yellow
}

# 2. Registry export — mod settings
$regDst = Join-Path $destDir 'mods-settings.reg'
reg export 'HKLM\SOFTWARE\Windhawk\Engine\Mods' $regDst /y 2>&1 | Out-Null
if ($LASTEXITCODE -eq 0) {
    Write-Host '  [OK] mods-settings.reg' -ForegroundColor Green
} else {
    Write-Host '  [WARN] reg export failed (needs admin)' -ForegroundColor Yellow
}
