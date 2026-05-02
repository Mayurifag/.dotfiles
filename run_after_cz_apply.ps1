$ahkProcesses = Get-CimInstance Win32_Process -Filter "Name like 'AutoHotkey%'" -ErrorAction SilentlyContinue |
    Where-Object { $_.CommandLine -like "*ahkv2.ahk*" }

foreach ($proc in $ahkProcesses) {
    Stop-Process -Id $proc.ProcessId -Force -ErrorAction SilentlyContinue
}

$ahkScript = Join-Path $env:USERPROFILE ".local\share\chezmoi\windows\ahkv2.ahk"
if (Test-Path $ahkScript) {
    Start-Process $ahkScript
}

# mpv-dark-box: clone repo and symlink dark-box.lua into mpv scripts dir
$darkBoxRepo   = Join-Path $env:USERPROFILE "Code\mpv-dark-box"
$darkBoxSource = Join-Path $darkBoxRepo "dark-box.lua"
$darkBoxTarget = Join-Path $env:USERPROFILE ".config\mpv\scripts\dark-box.lua"

if (-not (Test-Path $darkBoxRepo)) {
    $codeDir = Split-Path $darkBoxRepo -Parent
    if (-not (Test-Path $codeDir)) { New-Item -ItemType Directory -Force -Path $codeDir | Out-Null }
    Write-Host "[mpv-dark-box] Cloning into $darkBoxRepo"
    git clone --depth 1 https://github.com/Mayurifag/mpv-dark-box.git $darkBoxRepo
}

if (Test-Path $darkBoxSource) {
    $needLink = $true
    if (Test-Path $darkBoxTarget) {
        $item = Get-Item $darkBoxTarget -Force
        if ($item.LinkType -eq 'SymbolicLink' -and $item.Target -contains $darkBoxSource) {
            $needLink = $false
        } else {
            Remove-Item -Path $darkBoxTarget -Force
        }
    }
    if ($needLink) {
        Write-Host "[mpv-dark-box] Symlink: $darkBoxTarget -> $darkBoxSource"
        cmd /c mklink "$darkBoxTarget" "$darkBoxSource" | Out-Null
        if (-not (Test-Path $darkBoxTarget)) {
            Write-Host "[mpv-dark-box] ERROR: symlink failed (need Dev Mode or admin)" -ForegroundColor Red
        }
    }
} else {
    Write-Host "[mpv-dark-box] WARNING: $darkBoxSource missing — clone may have failed" -ForegroundColor Yellow
}
