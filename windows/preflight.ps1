# Preflight check for dotfiles setup — verifies all prerequisites before chezmoi init
# Run this in a NEW terminal after init.ps1 completes and manual steps (SSH + ejson) are done.
#
# Usage:
#   Invoke-RestMethod -Uri "https://raw.githubusercontent.com/Mayurifag/.dotfiles/master/windows/preflight.ps1" | Invoke-Expression

$ErrorActionPreference = "Continue"

Write-Host "--- Dotfiles Preflight Check ---" -ForegroundColor Cyan
Write-Host ""

# Warn if running as admin (not required)
if (([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  Write-Host "Note: Running as Administrator is not required for this script." -ForegroundColor Yellow
  Write-Host ""
}

$failed = @()

# Check 1: git
Write-Host -NoNewline "  git ............. "
if (Get-Command git -ErrorAction SilentlyContinue) {
  $gitVer = git --version 2>&1
  Write-Host "PASS ($gitVer)" -ForegroundColor Green
} else {
  Write-Host "FAIL" -ForegroundColor Red
  $failed += "git: not found. Run init.ps1 first (installs Git.Git via winget)."
}

# Check 2: bash (Git Bash)
Write-Host -NoNewline "  bash ............ "
if (Get-Command bash -ErrorAction SilentlyContinue) {
  $bashVer = bash --version 2>&1 | Select-Object -First 1
  Write-Host "PASS ($bashVer)" -ForegroundColor Green
} else {
  Write-Host "FAIL" -ForegroundColor Red
  $failed += "bash: not found. Git for Windows should provide it. Ensure 'C:\Program Files\Git\bin' is on PATH."
}

# Check 3: chezmoi
Write-Host -NoNewline "  chezmoi ......... "
$chezmoiCmd = Get-Command chezmoi -ErrorAction SilentlyContinue
if (!$chezmoiCmd) {
  # Try mise shims directly
  $miseShimPath = Join-Path $HOME ".local\share\mise\shims\chezmoi.cmd"
  if (Test-Path $miseShimPath) { $chezmoiCmd = $miseShimPath }
}
if ($chezmoiCmd) {
  $chezmoiVer = chezmoi --version 2>&1
  Write-Host "PASS ($chezmoiVer)" -ForegroundColor Green
} else {
  Write-Host "FAIL" -ForegroundColor Red
  $failed += "chezmoi: not found. Run init.ps1 first (installs via mise). Ensure mise shims are on PATH."
}

# Check 4: ejson
Write-Host -NoNewline "  ejson ........... "
if (Get-Command ejson -ErrorAction SilentlyContinue) {
  Write-Host "PASS" -ForegroundColor Green
} else {
  # Try common go bin path
  $goEjson = Join-Path $HOME "go\bin\ejson.exe"
  if (Test-Path $goEjson) {
    Write-Host "PASS (found at $goEjson — add Go bin to PATH)" -ForegroundColor Green
  } else {
    Write-Host "FAIL" -ForegroundColor Red
    $failed += "ejson: not found. Run init.ps1 first (installs via 'go install'). Ensure Go bin dir is on PATH."
  }
}

# Check 5: ejson keys directory
Write-Host -NoNewline "  ejson keys ...... "
$ejsonKeysDir = Join-Path $HOME ".ejson\keys"
if (Test-Path $ejsonKeysDir) {
  $keyFiles = Get-ChildItem $ejsonKeysDir -File -ErrorAction SilentlyContinue
  if ($keyFiles.Count -gt 0) {
    Write-Host "PASS ($($keyFiles.Count) key(s) found)" -ForegroundColor Green
  } else {
    Write-Host "FAIL" -ForegroundColor Red
    $failed += "ejson keys: directory exists but is empty. Symlink your keys directory."
  }
} else {
  Write-Host "FAIL" -ForegroundColor Red
  $failed += 'ejson keys: directory not found. Run: New-Item -ItemType Directory -Force "$env:USERPROFILE\.ejson" | Out-Null; cmd /c mklink /D "%USERPROFILE%\.ejson\keys" "D:\OpenCloud\Personal\Software\dotfiles\ejson\keys"'
}

# Check 6: EJSON_KEYDIR environment variable
Write-Host -NoNewline "  EJSON_KEYDIR ..... "
$ejsonKeyDirEnv = [System.Environment]::GetEnvironmentVariable("EJSON_KEYDIR", "User")
if ($ejsonKeyDirEnv) {
  Write-Host "PASS ($ejsonKeyDirEnv)" -ForegroundColor Green
} else {
  Write-Host "FAIL" -ForegroundColor Red
  $failed += "EJSON_KEYDIR: not set. ejson defaults to /opt/ejson/keys which does not exist on Windows. Run init.ps1 or set manually: [System.Environment]::SetEnvironmentVariable('EJSON_KEYDIR', `"`$env:USERPROFILE\.ejson\keys`", 'User')"
}

# Check 7: SSH key loaded
Write-Host -NoNewline "  ssh key ......... "
$sshOutput = ssh-add -l 2>&1
if ($LASTEXITCODE -eq 0 -and $sshOutput -notmatch "no identities") {
  $keyCount = ($sshOutput | Measure-Object -Line).Lines
  Write-Host "PASS ($keyCount key(s) loaded)" -ForegroundColor Green
} else {
  Write-Host "FAIL" -ForegroundColor Red
  $failed += "ssh key: no keys loaded. Open KeePassXC -> enable SSH Agent integration -> add your key."
}

Write-Host ""

# Results
if ($failed.Count -gt 0) {
  Write-Host "========================================" -ForegroundColor Red
  Write-Host "  PREFLIGHT FAILED — $($failed.Count) check(s) not passed" -ForegroundColor Red
  Write-Host "========================================" -ForegroundColor Red
  Write-Host ""
  foreach ($msg in $failed) {
    Write-Host "  - $msg" -ForegroundColor Yellow
  }
  Write-Host ""
  Write-Host "Fix the issues above and run this script again." -ForegroundColor White
  exit 1
}

Write-Host "========================================" -ForegroundColor Green
Write-Host "  ALL CHECKS PASSED" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Ready to initialize chezmoi with your dotfiles." -ForegroundColor White
Write-Host "This will run: chezmoi init git@github.com:Mayurifag/.dotfiles.git --ssh" -ForegroundColor White
Write-Host ""

Read-Host "Press Enter to continue, or Ctrl+C to cancel"

Write-Host ""
Write-Host "Running chezmoi init..." -ForegroundColor Cyan
chezmoi init git@github.com:Mayurifag/.dotfiles.git --ssh

if ($LASTEXITCODE -eq 0) {
  Write-Host ""
  Write-Host "========================================" -ForegroundColor Green
  Write-Host "  chezmoi init complete!" -ForegroundColor Green
  Write-Host "========================================" -ForegroundColor Green
  Write-Host ""
  Write-Host "Next steps:" -ForegroundColor Yellow
  Write-Host "  chezmoi diff    # preview changes" -ForegroundColor White
  Write-Host "  chezmoi apply   # apply dotfiles" -ForegroundColor White
} else {
  Write-Host ""
  Write-Host "chezmoi init failed. Check the error above." -ForegroundColor Red
  exit 1
}
