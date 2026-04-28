# windows/windhawk/backup.ps1
# Re-exports the current Windhawk state from the live machine back into this repo.
# Run this manually after changing mod settings in Windhawk so the dotfiles stay current.
#
# Usage:
#   pwsh -File "$env:USERPROFILE\.local\share\chezmoi\windows\windhawk\backup.ps1"
#   # or from within the chezmoi repo:
#   pwsh -File windows/windhawk/backup.ps1

[CmdletBinding()]
param([switch]$Quiet)

$ErrorActionPreference = 'Stop'

function Write-Info($msg, $color = 'Cyan') {
    if (-not $Quiet) { Write-Host $msg -ForegroundColor $color }
}

$scriptDir    = $PSScriptRoot
$windhawkData = 'C:\ProgramData\Windhawk'

Write-Info '[windhawk-backup] Exporting Windhawk config to dotfiles...'

# 1. userprofile.json
$profileSrc = Join-Path $windhawkData 'userprofile.json'
if (Test-Path $profileSrc) {
    Copy-Item -Path $profileSrc -Destination (Join-Path $scriptDir 'userprofile.json') -Force
    Write-Info '  [OK] userprofile.json' Green
} else {
    Write-Info '  [SKIP] userprofile.json not found at expected path' Yellow
}

# 2. Registry export — mod settings
$regDst = Join-Path $scriptDir 'mods-settings.reg'
reg export 'HKLM\SOFTWARE\Windhawk\Engine\Mods' $regDst /y | Out-Null
if ($LASTEXITCODE -eq 0) {
    # reg export outputs UTF-16 LE; convert to UTF-8 for editor compatibility
    $regContent = Get-Content $regDst -Encoding Unicode
    [System.IO.File]::WriteAllLines($regDst, $regContent, [System.Text.UTF8Encoding]::new($false))
    Write-Info '  [OK] mods-settings.reg (HKLM\SOFTWARE\Windhawk\Engine\Mods)' Green
} else {
    Write-Info '  [WARN] reg export failed (needs admin)' Yellow
}

if (-not $Quiet) {
    Write-Host ''
    Write-Host '[windhawk-backup] Done. Commit the changes to keep your dotfiles current:' -ForegroundColor Cyan
    Write-Host "  git -C '$scriptDir\..\..' add windows/windhawk/" -ForegroundColor White
    Write-Host "  git -C '$scriptDir\..\..' commit -m 'chore(windhawk): update mod settings backup'" -ForegroundColor White
}
