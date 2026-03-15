---
estimated_steps: 4
estimated_files: 1
---

# T03: Update INSTRUCTION.md and verify

**Slice:** S01 — Complete init.ps1 + preflight.ps1 + INSTRUCTION.md
**Milestone:** M007

## Description

Rewrite `windows/INSTRUCTION.md` to reflect the automated two-script bootstrap flow. Remove stale manual steps and TODOs that the scripts now handle. Keep remaining valid TODOs.

## Steps

1. Rewrite INSTRUCTION.md with these sections:
   - **System preparation** — keep existing content (admin, drivers, layout switch, winget). Keep the `init.ps1` download one-liner.
   - **Manual setup (after init.ps1)** — SSH key setup (KeePassXC SSH Agent, verify with `ssh-add -l`), ejson key symlink (`cmd /c mklink /D "%USERPROFILE%\.ejson\keys" "D:\OpenCloud\Personal\Software\dotfiles\ejson\keys"`).
   - **Preflight & chezmoi init** — `preflight.ps1` download one-liner (in a new terminal). Note that preflight verifies everything and runs `chezmoi init`.
   - **After chezmoi init** — `chezmoi diff`, `chezmoi apply`, `mise install` (for any new tools chezmoi config added).
   - **Other** — GPG key import, Obsidian, Browsers.app, Steam silent.
   - **TODO** — remaining valid items: VSCode sync, browser addons, gitkraken activation, PowerToys, espanso, AHK, Windows Terminal config, mise winget backend.
2. Remove stale TODOs: "Powershell profile" (handled by chezmoi M001), "Shared aliases between zsh and pwsh" (handled by M001).
3. Remove the old standalone ejson and chezmoi sections (now covered by the automated flow + manual setup section).
4. Final review: verify no stale content remains, all script references are correct, flow is coherent.

## Must-Haves

- [ ] INSTRUCTION.md references both `init.ps1` and `preflight.ps1` download commands
- [ ] No stale TODOs for "Powershell profile" or "Shared aliases"
- [ ] ejson key symlink path matches `D:\OpenCloud\Personal\Software\dotfiles\ejson\keys`
- [ ] SSH setup references KeePassXC SSH Agent
- [ ] Remaining valid TODOs preserved

## Verification

- `Select-String 'init.ps1' windows/INSTRUCTION.md` — confirms init reference
- `Select-String 'preflight.ps1' windows/INSTRUCTION.md` — confirms preflight reference
- `Select-String 'Powershell profile' windows/INSTRUCTION.md` returns no match (stale TODO removed)
- `Select-String 'Shared aliases' windows/INSTRUCTION.md` returns no match (stale TODO removed)
- `Select-String 'KeePassXC' windows/INSTRUCTION.md` — confirms SSH instructions
- `Select-String 'ejson' windows/INSTRUCTION.md` — confirms ejson instructions

## Inputs

- Current `windows/INSTRUCTION.md` — baseline to rewrite
- `windows/init.ps1` — reference for what the script now handles
- `windows/preflight.ps1` — reference for what the script checks

## Expected Output

- `windows/INSTRUCTION.md` — rewritten to reflect the two-script automated flow
