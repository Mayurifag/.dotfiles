#Requires -Version 7.4
$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true

$package = 'github:Kjerne/KJ-BatteryHub'
& mise --cd $HOME install --yes $package
$directory = (& mise --cd $HOME where $package).Trim()
$app = Join-Path $directory 'KJ-BatteryHub.exe'
if (-not (Test-Path -LiteralPath $app -PathType Leaf)) {
    throw "KJ-BatteryHub executable not found: $app"
}

$run = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'
if (-not (Test-Path -LiteralPath $run)) {
    New-Item -Path $run | Out-Null
}
New-ItemProperty -LiteralPath $run -Name 'KJ-BatteryHub' -Value "`"$app`"" -PropertyType String -Force | Out-Null

$legacy = Get-ItemPropertyValue -LiteralPath $run -Name 'WirelessBattery' -ErrorAction SilentlyContinue
if ($legacy -match '^".+[\\/]mise[\\/]installs[\\/]github-krisgfx9-wireless-device-battery-monitor[\\/].+[\\/]WirelessBattery\.exe"$') {
    Remove-ItemProperty -LiteralPath $run -Name 'WirelessBattery'
}
