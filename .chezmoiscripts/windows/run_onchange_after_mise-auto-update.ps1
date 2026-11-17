#Requires -Version 7.4
#Requires -RunAsAdministrator
$ErrorActionPreference = 'Stop'

$python = Join-Path $env:LOCALAPPDATA 'mise/shims/python.exe'
$script = Join-Path $HOME '.local/bin/mise-auto-update'
$logDir = Join-Path $HOME '.local/state/mise'
New-Item -ItemType Directory -Path $logDir -Force | Out-Null
$log = Join-Path $logDir 'auto-update.log'
$command = '""{0}" "{1}" > "{2}" 2>&1"' -f $python, $script, $log
$action = New-ScheduledTaskAction -Execute $env:ComSpec -Argument "/d /s /c $command" -WorkingDirectory $HOME
$principal = New-ScheduledTaskPrincipal -UserId ([Security.Principal.WindowsIdentity]::GetCurrent().Name) -LogonType S4U -RunLevel Limited
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
    -ExecutionTimeLimit (New-TimeSpan -Minutes 30) -MultipleInstances IgnoreNew -StartWhenAvailable
$trigger = New-ScheduledTaskTrigger -Daily -At '03:30'
Register-ScheduledTask -TaskName 'OpenCode Auto Update' -Action $action -Principal $principal `
    -Settings $settings -Trigger $trigger -Force | Out-Null
