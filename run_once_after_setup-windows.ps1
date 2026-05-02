# run_once_after_setup-windows.ps1
# One-time Windows setup tasks managed by chezmoi:
#   1. Prepend user-local tool directories to persistent User PATH
#   2. Symlink Windows Terminal settings.json to chezmoi source
#   3. Create AHK startup shortcut in shell:startup
#   4. Register scheduled task to kill stale gpg-agent sockets at logon
#   5. Remove stale WindowsTerminalSetup scheduled task (old dotfiles path)
#   6. Junction %APPDATA%\mpv -> ~/.config/mpv so mpv picks up chezmoi config

if ($env:OS -ne 'Windows_NT') { exit 0 }

$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------------------
# 1. User PATH
# ---------------------------------------------------------------------------
# Ensures user-local tool directories appear exactly once at the front of the
# persistent User PATH. Removes any duplicate/existing occurrences first, then
# prepends — so re-running is always safe and idempotent.

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
    Write-Host '[path] User PATH updated.'
} else {
    Write-Host '[path] User PATH already up to date.'
}

# ---------------------------------------------------------------------------
# 2. Windows Terminal symlink
# ---------------------------------------------------------------------------
# Symlinks Windows Terminal's settings.json directly to the chezmoi source at
# ~/.local/share/chezmoi/dot_config/windows-terminal/settings.json so that WT
# reads/writes the dotfiles repo copy in-place.
#
# Requires Developer Mode enabled (init.ps1 step 2 does this).

$source = Join-Path $env:USERPROFILE ".local\share\chezmoi\dot_config\windows-terminal\settings.json"
$wtLocalState = Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
$target = Join-Path $wtLocalState "settings.json"

# Verify source file exists in chezmoi source dir
if (-not (Test-Path $source)) {
    Write-Host "[wt] ERROR: Source file not found: $source" -ForegroundColor Red
    exit 1
}

# Verify WT LocalState directory exists (WT must have been launched at least once)
if (-not (Test-Path $wtLocalState)) {
    Write-Host "[wt] WARNING: Windows Terminal LocalState directory not found." -ForegroundColor Yellow
    Write-Host "     Launch Windows Terminal once, close it, then re-run 'chezmoi apply'." -ForegroundColor Yellow
    Write-Host "     Expected: $wtLocalState" -ForegroundColor Yellow
    exit 0
}

# Check Developer Mode (required for file symlinks without admin)
$devMode = $false
try {
    $regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
    $val = Get-ItemProperty -Path $regPath -Name "AllowDevelopmentWithoutDevLicense" -ErrorAction SilentlyContinue
    if ($val -and $val.AllowDevelopmentWithoutDevLicense -eq 1) { $devMode = $true }
} catch {}

if (-not $devMode) {
    Write-Host "[wt] ERROR: Developer Mode is not enabled." -ForegroundColor Red
    Write-Host "     File symlinks require Developer Mode. Run init.ps1 or enable in:" -ForegroundColor Red
    Write-Host "     Settings > System > For developers > Developer Mode" -ForegroundColor Red
    exit 1
}

# If target is already a symlink pointing to source, nothing to do
if (Test-Path $target) {
    $item = Get-Item $target -Force
    if ($item.LinkType -eq 'SymbolicLink' -and $item.Target -contains $source) {
        Write-Host "[wt] Symlink already correct: $target -> $source" -ForegroundColor Green
    } else {
        # Back up existing settings.json and recreate symlink
        $backup = Join-Path $wtLocalState "settings.json.bak"
        Write-Host "[wt] Backing up existing settings.json to settings.json.bak"
        Copy-Item -Path $target -Destination $backup -Force
        Remove-Item -Path $target -Force

        Write-Host "[wt] Creating symlink: $target -> $source"
        cmd /c mklink "$target" "$source" | Out-Null

        if (Test-Path $target) {
            Write-Host "[wt] Done. Windows Terminal will use chezmoi-managed settings." -ForegroundColor Green
            Write-Host "     Source: $source"
            Write-Host "     Target: $target"
        } else {
            Write-Host "[wt] ERROR: Symlink creation failed." -ForegroundColor Red
            Write-Host "     Try running: cmd /c mklink `"$target`" `"$source`"" -ForegroundColor Red
            exit 1
        }
    }
} else {
    Write-Host "[wt] Creating symlink: $target -> $source"
    cmd /c mklink "$target" "$source" | Out-Null

    if (Test-Path $target) {
        Write-Host "[wt] Done. Windows Terminal will use chezmoi-managed settings." -ForegroundColor Green
        Write-Host "     Source: $source"
        Write-Host "     Target: $target"
    } else {
        Write-Host "[wt] ERROR: Symlink creation failed." -ForegroundColor Red
        Write-Host "     Try running: cmd /c mklink `"$target`" `"$source`"" -ForegroundColor Red
        exit 1
    }
}

# ---------------------------------------------------------------------------
# 3. AHK Startup shortcut
# ---------------------------------------------------------------------------
# Creates a .lnk shortcut in the user's Startup folder pointing to the
# chezmoi source copy of ahkv2.ahk. Windows file association launches it
# via AutoHotkey. Idempotent: overwrites if the shortcut already exists.

$ahkSource = Join-Path $env:USERPROFILE ".local\share\chezmoi\windows\ahkv2.ahk"
$startupDir = [System.Environment]::GetFolderPath('Startup')
$shortcutPath = Join-Path $startupDir "ahkv2.ahk.lnk"

if (-not (Test-Path $ahkSource)) {
    Write-Host "[ahk] WARNING: AHK source file not found: $ahkSource" -ForegroundColor Yellow
    Write-Host "     Shortcut not created. Ensure chezmoi source is populated." -ForegroundColor Yellow
} else {
    $ws = New-Object -ComObject WScript.Shell
    $shortcut = $ws.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $ahkSource
    $shortcut.WorkingDirectory = Split-Path $ahkSource
    $shortcut.Description = "AutoHotkey v2 keyboard remapper (chezmoi-managed)"
    $shortcut.Save()

    Write-Host "[ahk] Done. AHK startup shortcut created." -ForegroundColor Green
    Write-Host "     Shortcut: $shortcutPath"
    Write-Host "     Target:   $ahkSource"
}

# ---------------------------------------------------------------------------
# 4. GPG agent cleanup at logon
# ---------------------------------------------------------------------------
# After a reboot, Windows kills gpg-agent but leaves stale socket files under
# %APPDATA%\gnupg. When git later tries to sign a commit, a fresh agent cannot
# bind to those sockets and retries in a loop until it fails (exit 128).
#
# Fix: register a Task Scheduler task that runs `gpgconf --kill gpg-agent` at
# every logon. GnuPG's own tool removes stale sockets cleanly so the agent
# starts fresh the first time it is needed.
#
# Trigger: AtLogon, current user only — runs in the user session context.
# Idempotent: -Force overwrites the task if it already exists.

$gpgconf = "C:\Program Files\GnuPG\bin\gpgconf.exe"

if (-not (Test-Path $gpgconf)) {
    Write-Host "[gpg] WARNING: gpgconf.exe not found at expected path: $gpgconf" -ForegroundColor Yellow
    Write-Host "     Skipping scheduled task - install GnuPG and re-run 'chezmoi apply'." -ForegroundColor Yellow
} else {
    $taskName = "GpgAgentCleanupAtLogon"
    $action   = New-ScheduledTaskAction -Execute $gpgconf -Argument "--kill gpg-agent"
    $trigger  = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME
    $settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Minutes 1) -StartWhenAvailable

    Register-ScheduledTask `
        -TaskName   $taskName `
        -Action     $action `
        -Trigger    $trigger `
        -Settings   $settings `
        -RunLevel   Limited `
        -Force | Out-Null

    Write-Host "[gpg] Done. Scheduled task '$taskName' registered." -ForegroundColor Green
    Write-Host "     gpgconf --kill gpg-agent will run at every logon for $env:USERNAME."
    Write-Host "     To apply immediately without rebooting, run once now:"
    Write-Host ("     `"" + $gpgconf + "`" --kill gpg-agent") -ForegroundColor Cyan
}

# ---------------------------------------------------------------------------
# 5. Remove stale WindowsTerminalSetup scheduled task
# ---------------------------------------------------------------------------
# An old scheduled task was registered when the dotfiles lived at
# C:\Users\Administrator\Code\.dotfiles. The script it points to no longer
# exists. Remove it so it stops firing silently on every login.

$staleTask = "WindowsTerminalSetup"
if (Get-ScheduledTask -TaskName $staleTask -ErrorAction SilentlyContinue) {
    Unregister-ScheduledTask -TaskName $staleTask -Confirm:$false
    Write-Host "[wt-task] Removed stale scheduled task '$staleTask'." -ForegroundColor Green
} else {
    Write-Host "[wt-task] Stale task '$staleTask' not present — nothing to remove." -ForegroundColor Green
}

# ---------------------------------------------------------------------------
# 6. mpv config junction
# ---------------------------------------------------------------------------
# mpv on Windows reads %APPDATA%\mpv by default. chezmoi writes its config to
# ~/.config/mpv. Junction the two so the dotfiles-managed config is what mpv
# loads. Junctions don't need admin/Developer Mode (unlike symlinks).

$mpvSource = Join-Path $env:USERPROFILE ".config\mpv"
$mpvTarget = Join-Path $env:APPDATA "mpv"

if (-not (Test-Path $mpvSource)) {
    Write-Host "[mpv] WARNING: chezmoi mpv config not found: $mpvSource" -ForegroundColor Yellow
    Write-Host "     Run 'chezmoi apply' first, then re-run this script." -ForegroundColor Yellow
} else {
    $needsLink = $true
    if (Test-Path $mpvTarget) {
        $item = Get-Item $mpvTarget -Force
        if ($item.LinkType -in @('Junction', 'SymbolicLink') -and $item.Target -contains $mpvSource) {
            Write-Host "[mpv] Junction already correct: $mpvTarget -> $mpvSource" -ForegroundColor Green
            $needsLink = $false
        } else {
            $backup = "$mpvTarget.bak"
            Write-Host "[mpv] Backing up existing $mpvTarget to $backup"
            if (Test-Path $backup) { Remove-Item -Path $backup -Recurse -Force }
            Move-Item -Path $mpvTarget -Destination $backup -Force
        }
    }

    if ($needsLink) {
        Write-Host "[mpv] Creating junction: $mpvTarget -> $mpvSource"
        cmd /c mklink /J "$mpvTarget" "$mpvSource" | Out-Null
        if (Test-Path $mpvTarget) {
            Write-Host "[mpv] Done. mpv will load config from chezmoi-managed dir." -ForegroundColor Green
        } else {
            Write-Host "[mpv] ERROR: Junction creation failed." -ForegroundColor Red
            exit 1
        }
    }
}
