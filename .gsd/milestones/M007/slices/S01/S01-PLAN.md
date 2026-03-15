# S01: Complete init.ps1 + preflight.ps1 + INSTRUCTION.md

**Goal:** Extend the Windows bootstrap pipeline from "winget apps installed" to "chezmoi init ready" with clear printed instructions for the two manual steps in between.
**Demo:** User runs `init.ps1` on fresh Windows → all tooling installed → instructions printed → user sets up SSH + ejson → runs `preflight.ps1` → all checks pass → `chezmoi init` runs.

## Must-Haves

- `init.ps1` installs GnuWin32.Make and adds its bin dir to session PATH
- `init.ps1` ensures Git's `usr/bin` is on PATH for POSIX utils (`cat`, `xargs`)
- `init.ps1` downloads mise config from raw GitHub, strips chezmoi template directives, writes to `~/.config/mise/config.toml`
- `init.ps1` runs `mise install` and `make mise-packages` successfully
- `init.ps1` prints SSH key instructions (KeePassXC SSH Agent + `ssh-add -l` verification)
- `init.ps1` prints ejson key symlink instruction (source: `D:\OpenCloud\Personal\Software\dotfiles\ejson\keys`, target: `~\.ejson\keys`)
- `init.ps1` prints the exact `Invoke-RestMethod ... | Invoke-Expression` command for `preflight.ps1` and emphasizes "in a new terminal"
- `preflight.ps1` checks 6 prerequisites: git, bash, chezmoi, ejson, ejson key dir, SSH key
- `preflight.ps1` prints what's missing and exits non-zero if any check fails
- `preflight.ps1` asks for confirmation before running `chezmoi init`
- `preflight.ps1` does NOT require Administrator
- `INSTRUCTION.md` reflects the two-script automated flow
- `GnuWin32.Make` is in `install/Wingetfile`

## Verification

- `Select-String 'GnuWin32.Make' install/Wingetfile` — confirms winget entry
- `Select-String 'make' windows/init.ps1` — confirms make install and invocation
- `Select-String 'mise install' windows/init.ps1` — confirms mise bootstrap
- `Select-String 'preflight' windows/init.ps1` — confirms preflight instructions printed
- `Select-String 'ssh-add' windows/preflight.ps1` — confirms SSH check
- `Select-String 'ejson' windows/preflight.ps1` — confirms ejson check
- `Select-String 'chezmoi init' windows/preflight.ps1` — confirms chezmoi init command
- `Select-String 'init.ps1' windows/INSTRUCTION.md` — confirms INSTRUCTION.md references init script
- `Select-String 'preflight' windows/INSTRUCTION.md` — confirms INSTRUCTION.md references preflight script
- Syntax check: `pwsh -NoProfile -Command "& { [System.Management.Automation.PSParser]::Tokenize((Get-Content 'windows/init.ps1' -Raw), [ref]$null) | Out-Null; 'VALID' }"` returns VALID
- Syntax check: `pwsh -NoProfile -Command "& { [System.Management.Automation.PSParser]::Tokenize((Get-Content 'windows/preflight.ps1' -Raw), [ref]$null) | Out-Null; 'VALID' }"` returns VALID

## Tasks

- [x] **T01: Add GnuWin32.Make to Wingetfile and extend init.ps1** `est:45m`
  - Why: init.ps1 currently stops at step 9/10 — need to add make install, mise config bootstrap, mise packages, and post-install instructions
  - Files: `install/Wingetfile`, `windows/init.ps1`
  - Do: Add `GnuWin32.Make` to Wingetfile (alphabetical). Extend init.ps1: after the existing PATH refresh (step 8), add steps for (1) verifying/adding GnuWin32 bin + Git usr/bin to PATH, (2) downloading mise config.toml.tmpl from raw GitHub, stripping `{{` lines, writing to `~/.config/mise/config.toml`, (3) running `mise install`, (4) running `make mise-packages` (from a temp clone/download of Makefile + makefiles/ + install/ or by running the individual package commands directly), (5) printing SSH/ejson/preflight instructions in a colored block. Renumber steps to reflect new total. Handle the Makefile problem: init.ps1 runs before the repo is cloned, so `make mise-packages` can't reference local files. Instead, download the required files (Makefile, makefiles/packages.mk, install/*file) to a temp dir and run make from there, OR run the individual package install commands directly in PowerShell without make. The direct approach is more reliable on Windows.
  - Verify: PS syntax check passes; grep confirms make, mise, preflight references in init.ps1
  - Done when: init.ps1 has all new steps, Wingetfile has GnuWin32.Make, PS syntax check passes

- [x] **T02: Create preflight.ps1** `est:25m`
  - Why: second downloadable script that verifies system readiness and runs chezmoi init
  - Files: `windows/preflight.ps1`
  - Do: Create preflight.ps1 with (1) explicit no-admin check (warn if running elevated — not needed), (2) 6 readiness checks: `git --version`, `bash --version`, `chezmoi --version`, `ejson version` or `Get-Command ejson`, `Test-Path "$HOME\.ejson\keys"` with at least one file inside, `ssh-add -l` exit code 0 and output not empty. Each check prints pass/fail with color. If any fail: print summary of what's missing and exit 1. If all pass: print success, ask `Read-Host "Press Enter to run chezmoi init, or Ctrl+C to cancel"`, then run `chezmoi init git@github.com:Mayurifag/.dotfiles.git --ssh`.
  - Verify: PS syntax check passes; grep confirms all 6 checks and chezmoi init command
  - Done when: preflight.ps1 exists, syntax-valid, contains all checks

- [x] **T03: Update INSTRUCTION.md and verify** `est:15m`
  - Why: INSTRUCTION.md has stale manual steps and TODOs that the scripts now handle
  - Files: `windows/INSTRUCTION.md`
  - Do: Rewrite to reflect the two-script flow: (1) system prep section stays (admin, drivers, layout switch, winget check), (2) init.ps1 download command, (3) manual steps section (SSH key via KeePassXC, ejson key symlink — matching what init.ps1 prints), (4) preflight.ps1 download command, (5) post-chezmoi section (chezmoi diff, chezmoi apply), (6) remaining TODOs that are still valid (VSCode, browser, gitkraken, PowerToys, espanso, AHK, Windows Terminal, mise winget backend). Remove TODOs that are now handled: "Powershell profile" (handled by chezmoi), "Shared aliases" (handled by M001). Remove the old ejson section (replaced by instructions in init.ps1 output + INSTRUCTION.md manual steps section). Remove old chezmoi section (replaced by preflight.ps1 flow).
  - Verify: grep confirms init.ps1 and preflight.ps1 references; no stale "Powershell profile" or "Shared aliases" TODOs remain
  - Done when: INSTRUCTION.md accurately describes the full flow from fresh Windows to working dotfiles

## Files Likely Touched

- `install/Wingetfile`
- `windows/init.ps1`
- `windows/preflight.ps1` (new)
- `windows/INSTRUCTION.md`
