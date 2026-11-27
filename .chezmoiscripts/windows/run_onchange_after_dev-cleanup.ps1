#Requires -Version 7.4
#Requires -RunAsAdministrator
$ErrorActionPreference = 'Stop'

$python = Join-Path $env:LOCALAPPDATA 'mise/shims/python.exe'
$script = Join-Path $HOME '.local/bin/dev-cleanup'
$command = '"set MISE_AUTO_INSTALL=0&& set MISE_NOT_FOUND_AUTO_INSTALL=0&& "{0}" "{1}" --scheduled"' -f $python, $script
$action = New-ScheduledTaskAction -Execute $env:ComSpec -Argument "/d /s /c $command" -WorkingDirectory $HOME
$principal = New-ScheduledTaskPrincipal -UserId ([Security.Principal.WindowsIdentity]::GetCurrent().User.Value) -LogonType S4U -RunLevel Limited
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
    -ExecutionTimeLimit (New-TimeSpan -Minutes 30) -MultipleInstances IgnoreNew -StartWhenAvailable
$trigger = New-ScheduledTaskTrigger -Daily -At '04:30'
Register-ScheduledTask -TaskName 'Developer Cleanup' -Action $action -Principal $principal `
    -Settings $settings -Trigger $trigger -Force | Out-Null
