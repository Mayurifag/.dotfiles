$ahkProcesses = Get-CimInstance Win32_Process -Filter "Name like 'AutoHotkey%'" -ErrorAction SilentlyContinue |
    Where-Object { $_.CommandLine -like "*ahkv2.ahk*" }

foreach ($proc in $ahkProcesses) {
    Stop-Process -Id $proc.ProcessId -Force -ErrorAction SilentlyContinue
}

$ahkScript = Join-Path $env:USERPROFILE ".local\share\chezmoi\windows\ahkv2.ahk"
if (Test-Path $ahkScript) {
    Start-Process $ahkScript
}
