<#
.SYNOPSIS
    Configure Windows Terminal with Dracula theme, JetBrains Mono Nerd Font, and quake-mode.
.DESCRIPTION
    Reads the existing Windows Terminal settings.json, merges in Dracula color scheme,
    JetBrains Mono Nerd Font as default profile font, globalSummon quake-mode (Win+``),
    tab cycling (Ctrl+Tab), split panes (Ctrl+\ / Ctrl+-), pane focus (Alt+arrows),
    and a _quake profile with initialRows=40 and focusMode disabled. Creates a backup before modifying.

    This script is idempotent -- safe to re-run. No admin privileges required.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"

# ---------------------------------------------------------------------------
# Locate Windows Terminal settings.json
# ---------------------------------------------------------------------------
$settingsPath = Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

if (-not (Test-Path $settingsPath)) {
    Write-Host "[ERROR] " -ForegroundColor Red -NoNewline
    Write-Host "Windows Terminal settings.json not found at: $settingsPath"
    Write-Host "        Is Windows Terminal installed from the Microsoft Store?"
    exit 1
}

Write-Host "Windows Terminal Setup" -ForegroundColor Cyan
Write-Host "======================" -ForegroundColor Cyan
Write-Host ""

# ---------------------------------------------------------------------------
# Backup existing settings
# ---------------------------------------------------------------------------
$backupPath = "$settingsPath.bak"
Copy-Item -Path $settingsPath -Destination $backupPath -Force
Write-Host "[OK]   " -ForegroundColor Green -NoNewline
Write-Host "Backup created: $backupPath"

# ---------------------------------------------------------------------------
# Read existing settings
# ---------------------------------------------------------------------------
$rawJson = Get-Content -Path $settingsPath -Raw
$settings = $rawJson | ConvertFrom-Json

Write-Host "[OK]   " -ForegroundColor Green -NoNewline
Write-Host "Settings loaded from: $settingsPath"

# ---------------------------------------------------------------------------
# Start on user login
# ---------------------------------------------------------------------------
if ($settings.PSObject.Properties["startOnUserLogin"]) {
    $settings.startOnUserLogin = $true
} else {
    $settings | Add-Member -NotePropertyName "startOnUserLogin" -NotePropertyValue $true -Force
}
Write-Host "[OK]   " -ForegroundColor Green -NoNewline
Write-Host "startOnUserLogin enabled"

# ---------------------------------------------------------------------------
# Set tab display options
# ---------------------------------------------------------------------------
if ($settings.PSObject.Properties["tabWidthMode"]) {
    $settings.tabWidthMode = "titleLength"
} else {
    $settings | Add-Member -NotePropertyName "tabWidthMode" -NotePropertyValue "titleLength" -Force
}
Write-Host "[OK]   " -ForegroundColor Green -NoNewline
Write-Host "Tab width mode set to titleLength"

if ($settings.PSObject.Properties["showTabsInTitleBar"]) {
    $settings.showTabsInTitleBar = $true
} else {
    $settings | Add-Member -NotePropertyName "showTabsInTitleBar" -NotePropertyValue $true -Force
}
Write-Host "[OK]   " -ForegroundColor Green -NoNewline
Write-Host "showTabsInTitleBar enabled"

# ---------------------------------------------------------------------------
# Add Dracula color scheme
# ---------------------------------------------------------------------------
$draculaScheme = @{
    name             = "Dracula"
    cursorColor      = "#F8F8F2"
    selectionBackground = "#44475A"
    background       = "#282A36"
    foreground       = "#F8F8F2"
    black            = "#21222C"
    blue             = "#BD93F9"
    cyan             = "#8BE9FD"
    green            = "#50FA7B"
    purple           = "#FF79C6"
    red              = "#FF5555"
    white            = "#F8F8F2"
    yellow           = "#F1FA8C"
    brightBlack      = "#6272A4"
    brightBlue       = "#D6ACFF"
    brightCyan       = "#A4FFFF"
    brightGreen      = "#69FF94"
    brightPurple     = "#FF92DF"
    brightRed        = "#FF6E6E"
    brightWhite      = "#FFFFFF"
    brightYellow     = "#FFFFA5"
}

# Ensure schemes is an array
if ($null -eq $settings.schemes) {
    $settings | Add-Member -NotePropertyName "schemes" -NotePropertyValue @() -Force
}

$existingDracula = $settings.schemes | Where-Object { $_.name -eq "Dracula" }
if ($existingDracula) {
    Write-Host "[SKIP] " -ForegroundColor Yellow -NoNewline
    Write-Host "Dracula color scheme already exists"
} else {
    # Convert to a list so we can add to it
    $schemesList = [System.Collections.ArrayList]@($settings.schemes)
    $schemeObj = [PSCustomObject]$draculaScheme
    [void]$schemesList.Add($schemeObj)
    $settings.schemes = $schemesList.ToArray()
    Write-Host "[OK]   " -ForegroundColor Green -NoNewline
    Write-Host "Dracula color scheme added"
}

# ---------------------------------------------------------------------------
# Set profile defaults (colorScheme + font)
# ---------------------------------------------------------------------------
# Ensure profiles.defaults exists
if ($null -eq $settings.profiles) {
    $settings | Add-Member -NotePropertyName "profiles" -NotePropertyValue ([PSCustomObject]@{
        defaults = [PSCustomObject]@{}
        list     = @()
    }) -Force
}

if ($null -eq $settings.profiles.defaults) {
    $settings.profiles | Add-Member -NotePropertyName "defaults" -NotePropertyValue ([PSCustomObject]@{}) -Force
}

$defaults = $settings.profiles.defaults

# Set color scheme
if ($defaults.PSObject.Properties["colorScheme"]) {
    $defaults.colorScheme = "Dracula"
} else {
    $defaults | Add-Member -NotePropertyName "colorScheme" -NotePropertyValue "Dracula" -Force
}
Write-Host "[OK]   " -ForegroundColor Green -NoNewline
Write-Host "Default color scheme set to Dracula"

# Set font
if ($defaults.PSObject.Properties["font"]) {
    $defaults.font | Add-Member -NotePropertyName "face" -NotePropertyValue "JetBrainsMono NF" -Force
    if ($defaults.font.PSObject.Properties["size"]) {
        $defaults.font.size = 12
    } else {
        $defaults.font | Add-Member -NotePropertyName "size" -NotePropertyValue 12 -Force
    }
} else {
    $fontObj = [PSCustomObject]@{
        face = "JetBrainsMono NF"
        size = 12
    }
    $defaults | Add-Member -NotePropertyName "font" -NotePropertyValue $fontObj -Force
}
Write-Host "[OK]   " -ForegroundColor Green -NoNewline
Write-Host "Default font set to JetBrainsMono NF (size 12)"

# ---------------------------------------------------------------------------
# Add globalSummon quake-mode action
# ---------------------------------------------------------------------------
# Ensure actions array exists
if ($null -eq $settings.actions) {
    $settings | Add-Member -NotePropertyName "actions" -NotePropertyValue @() -Force
}

$hasQuakeAction = $false
foreach ($action in $settings.actions) {
    if ($null -ne $action.command -and $action.command -is [PSCustomObject]) {
        if ($action.command.PSObject.Properties["action"] -and $action.command.action -eq "globalSummon") {
            $hasQuakeAction = $true
            break
        }
    }
}

if ($hasQuakeAction) {
    Write-Host "[SKIP] " -ForegroundColor Yellow -NoNewline
    Write-Host "globalSummon quake-mode action already exists"
} else {
    $quakeAction = [PSCustomObject]@{
        command = [PSCustomObject]@{
            action           = "globalSummon"
            name             = "_quake"
            dropdownDuration = 200
            toggleVisibility = $true
            monitor          = "toCurrent"
            desktop          = "toCurrent"
        }
        keys = "ctrl+``"
    }
    $actionsList = [System.Collections.ArrayList]@($settings.actions)
    [void]$actionsList.Add($quakeAction)
    $settings.actions = $actionsList.ToArray()
    Write-Host "[OK]   " -ForegroundColor Green -NoNewline
    Write-Host "globalSummon quake-mode action added (Ctrl+``)"
}

# ---------------------------------------------------------------------------
# Manage keybindings
# ---------------------------------------------------------------------------
# Ensure keybindings array exists
if ($null -eq $settings.keybindings) {
    $settings | Add-Member -NotePropertyName "keybindings" -NotePropertyValue @() -Force
}

$kbList = [System.Collections.ArrayList]@($settings.keybindings)

# Unbind Win+` (Windows Terminal default quake hotkey) so it doesn't conflict
$hasWinBacktickUnbound = $kbList | Where-Object { $_.keys -eq "win+``" -and $_.command -eq "unbound" }
if ($hasWinBacktickUnbound) {
    Write-Host "[SKIP] " -ForegroundColor Yellow -NoNewline
    Write-Host "win+`` already unbound"
} else {
    [void]$kbList.Add([PSCustomObject]@{ command = "unbound"; keys = "win+``" })
    Write-Host "[OK]   " -ForegroundColor Green -NoNewline
    Write-Host "win+`` unbound"
}

# Bind Ctrl+` and Alt+` to the globalSummon action
$quakeSummonId = "User.globalSummon.208E6F41"
foreach ($hotkey in @("ctrl+``", "alt+``")) {
    $existing = $kbList | Where-Object { $_.keys -eq $hotkey }
    if ($existing) {
        Write-Host "[SKIP] " -ForegroundColor Yellow -NoNewline
        Write-Host "$hotkey keybinding already exists"
    } else {
        [void]$kbList.Add([PSCustomObject]@{ id = $quakeSummonId; keys = $hotkey })
        Write-Host "[OK]   " -ForegroundColor Green -NoNewline
        Write-Host "$hotkey keybinding added (quake toggle)"
    }
}

# Helper: add keybinding if key not already bound
function Add-Keybinding($kbList, $keys, $id) {
    $existing = $kbList | Where-Object { $_.keys -eq $keys }
    if ($existing) {
        Write-Host "[SKIP] " -ForegroundColor Yellow -NoNewline
        Write-Host "Keybinding already exists: $keys"
    } else {
        [void]$kbList.Add([PSCustomObject]@{ id = $id; keys = $keys })
        Write-Host "[OK]   " -ForegroundColor Green -NoNewline
        Write-Host "Keybinding added: $keys -> $id"
    }
}

# Helper: add action if ID not already present
function Add-Action($actionsList, $id, $cmd) {
    $existingIds = @($actionsList | ForEach-Object { $_.id })
    if ($existingIds -notcontains $id) {
        [void]$actionsList.Add([PSCustomObject]@{ command = $cmd; id = $id })
        Write-Host "[OK]   " -ForegroundColor Green -NoNewline
        Write-Host "Action added: $id"
    } else {
        Write-Host "[SKIP] " -ForegroundColor Yellow -NoNewline
        Write-Host "Action already exists: $id"
    }
}

$actionsList = [System.Collections.ArrayList]@($settings.actions)

# Tab: Ctrl+T new tab, Ctrl+Tab / Ctrl+Shift+Tab cycle
Add-Keybinding $kbList "ctrl+t"         "Terminal.OpenNewTab"
Add-Keybinding $kbList "ctrl+tab"       "Terminal.NextTab"
Add-Keybinding $kbList "ctrl+shift+tab" "Terminal.PrevTab"

# Split panes
Add-Action $actionsList "User.splitPaneRight.0" ([PSCustomObject]@{ action="splitPane"; split="right" })
Add-Keybinding $kbList "ctrl+\" "User.splitPaneRight.0"

Add-Action $actionsList "User.splitPaneDown.0" ([PSCustomObject]@{ action="splitPane"; split="down" })
Add-Keybinding $kbList "ctrl+-" "User.splitPaneDown.0"

# Move focus between panes (alt+arrows)
$moveDirs = @(
    @{ dir="left";  keys="alt+left"  },
    @{ dir="right"; keys="alt+right" },
    @{ dir="up";    keys="alt+up"    },
    @{ dir="down";  keys="alt+down"  }
)
foreach ($entry in $moveDirs) {
    $cap = $entry.dir.Substring(0,1).ToUpper() + $entry.dir.Substring(1)
    $aid = "User.moveFocus$cap.0"
    Add-Action $actionsList $aid ([PSCustomObject]@{ action="moveFocus"; direction=$entry.dir })
    Add-Keybinding $kbList $entry.keys $aid
}

$settings.actions     = $actionsList.ToArray()
$settings.keybindings = $kbList.ToArray()

# ---------------------------------------------------------------------------
# Quake profile: set initialRows
# ---------------------------------------------------------------------------
$profileList = [System.Collections.ArrayList]@($settings.profiles.list)
$quakeProfile = $profileList | Where-Object { $_.name -eq "_quake" }
if ($quakeProfile) {
    $quakeProfile | Add-Member -NotePropertyName "initialRows" -NotePropertyValue 40 -Force
    $quakeProfile | Add-Member -NotePropertyName "focusMode" -NotePropertyValue $false -Force
    Write-Host "[OK]   " -ForegroundColor Green -NoNewline
    Write-Host "_quake profile: initialRows set to 40, focusMode disabled"
} else {
    [void]$profileList.Add([PSCustomObject]@{ name="_quake"; initialRows=40; hidden=$true; focusMode=$false })
    $settings.profiles.list = $profileList.ToArray()
    Write-Host "[OK]   " -ForegroundColor Green -NoNewline
    Write-Host "_quake profile added with initialRows=40, focusMode disabled"
}

# ---------------------------------------------------------------------------
# Write settings back
# ---------------------------------------------------------------------------
$outputJson = $settings | ConvertTo-Json -Depth 20
Set-Content -Path $settingsPath -Value $outputJson -Encoding UTF8
Write-Host ""
Write-Host "[OK]   " -ForegroundColor Green -NoNewline
Write-Host "Settings written to: $settingsPath"
Write-Host ""
Write-Host "Done! Restart Windows Terminal to apply changes." -ForegroundColor Cyan
