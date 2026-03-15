# run_once_after_set-user-path-windows.ps1
# Ensures user-local tool directories appear exactly once at the front of the
# persistent User PATH. Removes any duplicate/existing occurrences first, then
# prepends — so re-running is always safe and idempotent.

if ($env:OS -ne 'Windows_NT') { exit 0 }

$dirs = @(
    "$env:USERPROFILE\.cargo\bin",
    "C:\Program Files\Git\usr\bin",
    "C:\Program Files (x86)\GnuWin32\bin"
)

$current  = [System.Environment]::GetEnvironmentVariable('PATH', 'User')
$entries  = $current -split ';' | Where-Object { $_ -ne '' }

# Strip all existing occurrences of managed dirs (case-insensitive), then prepend
$newEntries = $entries | Where-Object { $dirs -inotcontains $_ }
$newEntries = $dirs + $newEntries

$newPath = $newEntries -join ';'
$oldPath = $entries   -join ';'

if ($newPath -ine $oldPath) {
    [System.Environment]::SetEnvironmentVariable('PATH', $newPath, 'User')
    Write-Host 'User PATH updated.'
} else {
    Write-Host 'User PATH already up to date.'
}
