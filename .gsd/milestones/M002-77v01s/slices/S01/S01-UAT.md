# S01: Mise-managed claude-code with cleanup — UAT

**Milestone:** M002-77v01s
**Written:** 2026-03-15

## UAT Type

- UAT mode: artifact-driven + live-runtime
- Why this mode is sufficient: All Linux deliverables are already deployed and can be verified via file inspection and live binary invocation. Windows verification (npm fallback) requires a human on a Windows machine and is explicitly noted as out of scope for automated UAT.

## Preconditions

- `chezmoi apply` has been run on the Linux machine (already done in T04)
- `mise install` has been run (already done in T04, claude-code 2.1.76 installed)
- No manual re-application needed for artifact-driven checks; for runtime checks, the shim at `~/.local/share/mise/shims/claude` must exist

## Smoke Test

```bash
~/.local/share/mise/shims/claude --version
```
**Expected:** `2.1.76 (Claude Code)` (or later version if reinstalled). Any version string confirms mise-managed binary is working.

---

## Test Cases

### 1. claude-code entry present in deployed mise config

```bash
grep 'claude-code' ~/.config/mise/config.toml
```
1. Run the command above.
2. **Expected:** `claude-code = "latest"` — exactly this line, inside the `[tools]` section.
3. **Fail signal:** No output, or output showing a different value (e.g. a pinned version or wrong key name).

---

### 2. claude-code entry present in chezmoi source

```bash
grep 'claude-code' /home/mayurifag/.local/share/chezmoi/dot_config/mise/config.toml
```
1. Run the command above.
2. **Expected:** `claude-code = "latest"`.
3. **Fail signal:** No output — means the chezmoi source was not updated and the deployed config may come from a stale state.

---

### 3. chezmoi dry-run produces no errors

```bash
chezmoi apply --dry-run --force 2>&1 | grep -i error
```
1. Run the command above.
2. **Expected:** Empty output (exit 1 from grep is normal — it means no error lines matched).
3. **Fail signal:** Any line containing "error" in the output.

---

### 4. Old claude symlink is absent

```bash
[ -L ~/.local/bin/claude ] && echo SYMLINK_STILL_EXISTS || echo SYMLINK_GONE
```
1. Run the command above.
2. **Expected:** `SYMLINK_GONE`.
3. **Fail signal:** `SYMLINK_STILL_EXISTS` — the run_once script did not fire, or the symlink was recreated by another process.

---

### 5. Old claude data directory is absent

```bash
[ -d ~/.local/share/claude ] && echo DIR_STILL_EXISTS || echo DIR_GONE
```
1. Run the command above.
2. **Expected:** `DIR_GONE`.
3. **Fail signal:** `DIR_STILL_EXISTS` — the run_once script did not fire, or the directory was recreated.

---

### 6. run_once cleanup script is tracked by chezmoi

```bash
chezmoi managed --include=scripts 2>/dev/null | grep remove-old-claude
```
1. Run the command above.
2. **Expected:** `remove-old-claude-install.sh` appears in output.
3. **Fail signal:** No output — means chezmoi does not recognise the script, likely due to incorrect filename prefix or missing executable bit.

---

### 7. mise shows claude-code installed and sourced from config

```bash
mise list claude-code
```
1. Run the command above.
2. **Expected:** A line like `claude-code  2.1.76  ~/.config/mise/config.toml  latest` — version, config path, and requested spec all present.
3. **Fail signal:** Empty output (not installed), or config path is absent/wrong.

---

### 8. claude binary resolves and outputs a version

```bash
mise which claude
```
1. Run the command above.
2. **Expected:** A path under `~/.local/share/mise/installs/claude-code/` (e.g. `~/.local/share/mise/installs/claude-code/2.1.76/claude`).
3. Run `~/.local/share/mise/shims/claude --version`.
4. **Expected:** Version string such as `2.1.76 (Claude Code)`.
5. **Fail signal:** `command not found`, empty output, or a path pointing to `~/.local/bin/claude` (old symlink location — means cleanup failed or PATH is wrong).

---

### 9. windows/INSTRUCTION.md contains no manual claude install TODO

```bash
grep -in 'claude' /home/mayurifag/.local/share/chezmoi/windows/INSTRUCTION.md
```
1. Run the command above.
2. **Expected:** No output (exit 1 from grep). No claude references remain in the file.
3. **Fail signal:** Any output — especially a line containing `TODO`, `install`, `bash`, or `PowerShell` alongside `claude`.

---

## Edge Cases

### run_once script is idempotent when targets are already absent

1. Confirm symlink and directory are already gone (Tests 4 and 5 pass).
2. Force re-run of the script: `chezmoi state delete-bucket --bucket=scriptState && chezmoi apply --force`.
3. **Expected:** Script runs again without error; symlink and directory remain absent; no shell errors from `rm -f` / `rm -rf` on non-existent targets.
4. **Fail signal:** Script exits non-zero, or output contains `No such file or directory` errors (would indicate missing `-f`/`-rf` flags).

### run_once script is a no-op on non-Linux

1. On a macOS or Windows machine: inspect the script at `~/.local/share/chezmoi/run_once_remove-old-claude-install.sh`.
2. Check the OS guard: `head -8 run_once_remove-old-claude-install.sh`.
3. **Expected:** Lines 4–6 contain `if [ "$(uname -s)" != "Linux" ]; then exit 0; fi` (or equivalent).
4. **Fail signal:** No OS guard present — script would attempt `rm` operations unconditionally on macOS/Windows.

### chezmoi apply --dry-run is safe (no destructive preview)

1. Run `chezmoi apply --dry-run --force 2>&1`.
2. **Expected:** Output shows planned file operations but makes no changes; run_once script does not execute in dry-run mode.
3. **Fail signal:** Any actual file deletion or modification on disk during dry-run.

---

## Failure Signals

- `SYMLINK_STILL_EXISTS` — run_once script did not fire; check `chezmoi status | grep '^R'` and `chezmoi managed --include=scripts`
- `DIR_STILL_EXISTS` — same as above
- `chezmoi apply --dry-run` produces error lines — likely a TOML parse error in `dot_config/mise/config.toml`
- `mise list claude-code` returns empty — `chezmoi apply` was not run, or `mise install` was not run
- `mise which claude` points to `~/.local/bin/claude` — old symlink was not removed; cleanup script may not have run
- `grep 'claude' windows/INSTRUCTION.md` returns output — the TODO line was not removed from the source file

---

## Requirements Proved By This UAT

- none — M002-77v01s is a new capability milestone with no prior REQUIREMENTS.md entries; all verification is milestone-DoD driven

## Not Proven By This UAT

- Windows: `mise install` using npm fallback and `claude --version` working in PowerShell or Git Bash — requires human on Windows machine
- Behaviour on a truly fresh machine (where neither chezmoi state nor the old install exists) — not testable on the current machine
- Long-term: `claude-code = "latest"` resolving a future version after an upstream release — mise will auto-update on next `mise install` / `mise upgrade`

## Notes for Tester

- In the agent shell (non-interactive), mise shims are not on PATH. Use `~/.local/share/mise/shims/claude --version` or `mise which claude` instead of bare `claude --version`. In a real user login shell (which sources `.bashrc`/`.zshrc` → `mise activate`), `claude` works directly.
- The run_once script fires at most once per machine unless `chezmoi state delete-bucket --bucket=scriptState` is used to reset state. This is intentional.
- `chezmoi apply --force` is safe when pre-existing MM-status files (e.g. konsole profile) would otherwise trigger an interactive prompt in non-TTY environments.
- Windows UAT is a human responsibility — open `windows/INSTRUCTION.md`, confirm the old TODO is gone, then run `mise install` in Git Bash or PowerShell and verify `claude --version`.
