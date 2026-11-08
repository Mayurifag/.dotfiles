# Vicinae is not yet available through WinGet. The installed app updates itself.
$ErrorActionPreference = 'Stop'

$installed = Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*' -ErrorAction SilentlyContinue |
    Where-Object { $_.DisplayName -eq 'Vicinae' } |
    Select-Object -First 1
if ($installed) {
    Write-Host "Vicinae $($installed.DisplayVersion) is already installed; use its built-in updater."
    return
}
if (Get-Process -Name 'vicinae-server' -ErrorAction SilentlyContinue) {
    throw 'Close the running Vicinae server before installing.'
}

$version = 'v0.29.2'
$sha256 = '3259f0463f9e62b2020f6e3ac51d809ceffd30b91895167f9c611078f794ff39'
$tempRoot = Join-Path $env:LOCALAPPDATA 'Temp\opencode'
if (-not (Test-Path $tempRoot)) { $tempRoot = $env:TEMP }
$tempDir = Join-Path $tempRoot "vicinae-install-$([guid]::NewGuid().ToString('N'))"
New-Item -ItemType Directory -Path $tempDir | Out-Null
try {
    gh release download $version --repo vicinaehq/vicinae --pattern 'vicinae-x64-setup.exe' --dir $tempDir
    if ($LASTEXITCODE -ne 0) { throw 'Vicinae installer download failed.' }
    $installer = Join-Path $tempDir 'vicinae-x64-setup.exe'
    if ((Get-FileHash -Algorithm SHA256 $installer).Hash -ne $sha256) { throw 'Vicinae installer hash mismatch.' }
    $signature = Get-AuthenticodeSignature $installer
    if ($signature.Status -ne 'Valid') { throw "Vicinae installer signature is $($signature.Status)." }
    $setup = Start-Process -FilePath $installer -ArgumentList '/VERYSILENT', '/SUPPRESSMSGBOXES', '/NORESTART', '/TASKS=autostart' -Wait -PassThru
    if ($setup.ExitCode -ne 0) { throw "Vicinae installer failed with exit code $($setup.ExitCode)." }
    Write-Host "Installed Vicinae $version with startup enabled."
} finally {
    Remove-Item -LiteralPath $tempDir -Recurse -Force
}
