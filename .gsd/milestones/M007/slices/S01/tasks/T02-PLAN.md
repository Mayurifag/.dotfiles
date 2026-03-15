---
estimated_steps: 5
estimated_files: 1
---

# T02: Create preflight.ps1

**Slice:** S01 — Complete init.ps1 + preflight.ps1 + INSTRUCTION.md
**Milestone:** M007

## Description

Create `windows/preflight.ps1` — a downloadable PowerShell script that verifies all prerequisites for chezmoi init are met (git, bash, chezmoi, ejson, ejson key, SSH key) and offers to run `chezmoi init git@github.com:Mayurifag/.dotfiles.git --ssh` when everything checks out. Does NOT require Administrator.

## Steps

1. Create `windows/preflight.ps1` with a header comment explaining its purpose and that it should be run in a new terminal after init.ps1.
2. Add an admin-elevation warning: if running as admin, print a yellow warning that admin is not needed (but don't block — it still works).
3. Implement the 6 readiness checks, each printing a green PASS or red FAIL line:
   - `git --version` — exit code 0
   - `bash --version` — exit code 0 (Git Bash)
   - `chezmoi --version` — exit code 0 (mise-installed)
   - `ejson version` or `Get-Command ejson` — available on PATH (go-installed)
   - `Test-Path "$HOME\.ejson\keys"` — directory exists and contains at least one file
   - `ssh-add -l` — exit code 0 and output is not "The agent has no identities"
4. If any check fails: print a summary of what's missing with actionable fix hints, then exit 1.
5. If all pass: print success message, prompt with `Read-Host "Press Enter to run chezmoi init, or Ctrl+C to cancel"`, then run `chezmoi init git@github.com:Mayurifag/.dotfiles.git --ssh`.

## Must-Haves

- [ ] 6 readiness checks implemented with colored pass/fail output
- [ ] Blocks with clear error messages if any check fails
- [ ] Runs `chezmoi init git@github.com:Mayurifag/.dotfiles.git --ssh` after user confirmation
- [ ] Does not require or enforce Administrator
- [ ] PS syntax check passes

## Verification

- `pwsh -NoProfile -Command "& { [System.Management.Automation.PSParser]::Tokenize((Get-Content 'windows/preflight.ps1' -Raw), [ref]$null) | Out-Null; 'VALID' }"` returns VALID
- `Select-String 'git' windows/preflight.ps1` — confirms git check
- `Select-String 'bash' windows/preflight.ps1` — confirms bash check
- `Select-String 'chezmoi' windows/preflight.ps1` — confirms chezmoi check
- `Select-String 'ejson' windows/preflight.ps1` — confirms ejson check
- `Select-String 'ssh-add' windows/preflight.ps1` — confirms SSH check
- `Select-String 'chezmoi init' windows/preflight.ps1` — confirms init command

## Inputs

- M007 context: preflight must check git, bash, chezmoi, ejson, ejson keys at `~\.ejson\keys`, SSH key via `ssh-add -l`
- M007 context: `chezmoi init git@github.com:Mayurifag/.dotfiles.git --ssh` is the init command

## Expected Output

- `windows/preflight.ps1` — new file, syntax-valid, contains all checks and chezmoi init
