# windows/powertoys-backup/backup.ps1
# Re-exports current PowerToys config from the live machine back into this repo.
# Only backs up modules listed as enabled in settings.json. Disabled modules are pruned.
#
# Usage:
#   pwsh -File "$env:USERPROFILE\.local\share\chezmoi\windows\powertoys-backup\backup.ps1"
#   # or from within the chezmoi repo:
#   pwsh -File windows/powertoys-backup/backup.ps1

[CmdletBinding()]
param([switch]$Quiet)

$ErrorActionPreference = 'Stop'

function Write-Info($msg, $color = 'Cyan') {
    if (-not $Quiet) { Write-Host $msg -ForegroundColor $color }
}

$scriptDir = $PSScriptRoot
$ptSrc     = Join-Path $env:LOCALAPPDATA 'Microsoft\PowerToys'
$ptDst     = Join-Path $scriptDir 'PowerToys'
$cpDst     = Join-Path $scriptDir 'CommandPalette'
$cpSrc     = Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.CommandPalette_8wekyb3d8bbwe\LocalState\settings.json'

Write-Info '[powertoys-backup] Exporting PowerToys config to dotfiles...'

$globalFile = Join-Path $ptSrc 'settings.json'
if (-not (Test-Path $globalFile)) {
    Write-Info '  [SKIP] PowerToys settings.json not found.' Yellow
    return
}

# Module key (settings.json) → on-disk dir name. Identity by default; only list mismatches.
$moduleDirMap = @{
    'File Explorer Preview' = 'File Explorer'
}

$global = Get-Content $globalFile -Raw | ConvertFrom-Json
$enabledModules = @(
    $global.enabled.PSObject.Properties |
        Where-Object { $_.Value } |
        ForEach-Object { $_.Name }
)
$enabledDirs = @($enabledModules | ForEach-Object {
    if ($moduleDirMap.ContainsKey($_)) { $moduleDirMap[$_] } else { $_ }
})

if (-not (Test-Path $ptDst)) { New-Item -ItemType Directory -Path $ptDst | Out-Null }

# Global settings.json
Copy-Item $globalFile (Join-Path $ptDst 'settings.json') -Force

# Per-module dirs (enabled only) — settings files only, exclude logs/caches
foreach ($dirName in $enabledDirs) {
    $srcDir = Join-Path $ptSrc $dirName
    $dstDir = Join-Path $ptDst $dirName
    if (-not (Test-Path $srcDir)) { continue }
    if (Test-Path $dstDir) { Remove-Item -Recurse -Force $dstDir }

    $files = Get-ChildItem $srcDir -Recurse -File -ErrorAction SilentlyContinue | Where-Object {
        ($_.Extension -in '.json', '.xml') -and
        ($_.FullName -notmatch '\\(Logs|Cache)\\') -and
        ($_.Name -notmatch '(?i)(cache|history|userselectedrecord|placement)\.json$')
    }
    foreach ($f in $files) {
        $rel = $f.FullName.Substring($srcDir.Length).TrimStart('\')
        $target = Join-Path $dstDir $rel
        $targetParent = Split-Path $target -Parent
        if (-not (Test-Path $targetParent)) { New-Item -ItemType Directory -Path $targetParent -Force | Out-Null }
        Copy-Item $f.FullName $target -Force
    }
}

# Prune dirs whose module is no longer enabled
Get-ChildItem $ptDst -Directory | Where-Object { $enabledDirs -notcontains $_.Name } | ForEach-Object {
    Remove-Item -Recurse -Force $_.FullName
}

# Prune stale top-level files (keep only settings.json)
Get-ChildItem $ptDst -File | Where-Object { $_.Name -ne 'settings.json' } | Remove-Item -Force

# Sanitize fields that change on every PT launch (timestamps, counters, time-based example
# strings) so git diffs stay meaningful instead of churning on activity noise.
function Update-FileText {
    param([string]$Path, [scriptblock]$Transform)
    if (-not (Test-Path $Path)) { return }
    $text = [IO.File]::ReadAllText($Path)
    $new  = & $Transform $text
    if ($new -ne $text) {
        [IO.File]::WriteAllText($Path, $new, [Text.UTF8Encoding]::new($false))
    }
}

$runRoot = Join-Path $ptDst 'PowerToys Run'
Update-FileText (Join-Path $runRoot 'Settings\Plugins\Microsoft.Plugin.Program\ProgramPluginSettings.json') {
    param($t)
    $t -replace '"LastIndexTime"\s*:\s*"[^"]*"', '"LastIndexTime": "2026-01-01T00:00:00+04:00"'
}
Update-FileText (Join-Path $runRoot 'Settings\PowerToysRunSettings.json') {
    param($t)
    $t -replace '"ActivateTimes"\s*:\s*\d+', '"ActivateTimes": 100'
}
Update-FileText (Join-Path $runRoot 'settings.json') {
    param($t)
    $t = $t -replace 'Day::\d{2}-[A-Za-z]{3}-\d{2}', 'Day::01-Jan-26'
    $t = $t -replace 'Time::\d{2}:\d{2}:\d{2}', 'Time::12:00:00'
    $t = $t -replace 'Calendar week::\d{2}-[A-Za-z]{3}-\d{2}', 'Calendar week::01-Jan-26'
    $t
}

# CmdPal MSIX settings (only if CmdPal module is enabled)
if ($enabledModules -contains 'CmdPal' -and (Test-Path $cpSrc)) {
    if (-not (Test-Path $cpDst)) { New-Item -ItemType Directory -Path $cpDst | Out-Null }
    Copy-Item $cpSrc (Join-Path $cpDst 'settings.json') -Force
    Write-Info '  [OK] CmdPal MSIX settings' Green
} elseif (Test-Path $cpDst) {
    Remove-Item -Recurse -Force $cpDst
}

Write-Info "  [OK] PowerToys ($($enabledModules.Count) enabled modules backed up)" Green
