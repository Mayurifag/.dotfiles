# run_after_backup.ps1
# Exports current Windhawk + PowerToys state back into the dotfiles repo on every chezmoi apply.
# Delegates to the per-tool manual backup scripts in -Quiet mode.

if ($env:OS -ne 'Windows_NT') { exit 0 }

$repo = Join-Path $env:USERPROFILE '.local\share\chezmoi'

$scripts = @(
    @{ Name = 'windhawk';   Path = Join-Path $repo 'windows\windhawk\backup.ps1';          Probe = 'C:\Program Files\Windhawk\windhawk.exe' }
    @{ Name = 'powertoys';  Path = Join-Path $repo 'windows\powertoys-backup\backup.ps1';  Probe = (Join-Path $env:LOCALAPPDATA 'Microsoft\PowerToys\settings.json') }
)

foreach ($s in $scripts) {
    if (-not (Test-Path $s.Probe)) {
        Write-Host "[$($s.Name)-backup] Not installed — skipping." -ForegroundColor Yellow
        continue
    }
    & $s.Path -Quiet
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[$($s.Name)-backup] failed (exit $LASTEXITCODE)" -ForegroundColor Yellow
    } else {
        Write-Host "[$($s.Name)-backup] OK" -ForegroundColor Green
    }
}
