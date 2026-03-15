---
estimated_steps: 3
estimated_files: 1
---

# T03: Update windows/INSTRUCTION.md

**Slice:** S01 — Mise-managed claude-code with cleanup
**Milestone:** M002-77v01s

## Description

Update `windows/INSTRUCTION.md` to remove the open TODO about claude installation and add a note that mise (already listed in `Wingetfile` and set up during chezmoi apply) handles claude automatically via `mise install`. The TODO item "Even though PowerShell profile will have mise, install it also for bash in windows for claude" is now superseded — mise's `claude-code = "latest"` entry handles it.

## Steps

1. Open `windows/INSTRUCTION.md`
2. Remove the TODO item: `- [ ] Even though PowerShell profile will have mise, install it also for bash in windows for claude`
3. Optionally add a brief note in the Chezmoi section or Other section that `mise install` (run after `chezmoi apply`) installs claude-code automatically
4. Save the file

## Must-Haves

- [ ] The manual claude install TODO is removed from the TODO list
- [ ] File remains valid Markdown
- [ ] Existing content not disrupted

## Verification

- `grep -n 'claude' windows/INSTRUCTION.md` — should not contain the old TODO line; may contain a positive note about mise handling it

## Inputs

- `windows/INSTRUCTION.md` — current manual instruction doc with open claude TODO

## Expected Output

- `windows/INSTRUCTION.md` — updated doc with claude TODO removed; mise handles it automatically
