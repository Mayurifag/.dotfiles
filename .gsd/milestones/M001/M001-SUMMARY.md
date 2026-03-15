---
id: M001
provides:
  - Cross-shell alias and env-var sharing via chezmoi templates (zsh, PowerShell, Git Bash)
  - Single-source aliases_posix and aliases_ps1 fragments consumed by all three shells
  - Chezmoi-managed PowerShell 7 profile with mise/zoxide/starship activation
  - Chezmoi-managed dot_bashrc.tmpl with Windows OpenSSH agent routing for Git Bash
  - OS-conditional deployment via .chezmoiignore (Documents/ gated to Windows only)
key_decisions:
  - Chezmoi compile-time template generation (not runtime sourcing) for per-shell files
  - aliases_posix and aliases_ps1 as explicit blocks (not TOML-data range iteration) — simpler at this scale
  - Git Bash gets no zoxide/starship — minimal setup for Claude-only use
  - dot_bashrc.tmpl uses inline OS conditions, not .chezmoiignore, so file deploys on both platforms
  - SSH routing via GIT_SSH + SSH_AUTH_SOCK named pipe — zero new dependencies
  - czapply override after aliases_posix include — bash cannot source .zshrc
  - eza aliases unconditional in shared fragment — consistent with PS/Git Bash behavior
  - No line-endings directive in 40-aliases.zsh.tmpl — Linux-only, no CRLF risk
patterns_established:
  - Template fragment include: always pass trailing dot — {{ template "name" . }}
  - POSIX inline env-var syntax (LEFTHOOK=0 cmd) translated to explicit $env: block in PS
  - All PS aliases as function blocks (not Set-Alias) to support argument passthrough via @args
  - Secrets via ejsonDecrypt in template fragments, never in .chezmoidata.toml
observability_surfaces:
  - chezmoi execute-template — validate fragments render without error on Linux
  - chezmoi apply --dry-run — confirm Documents/ excluded on Linux
  - chezmoi data — confirm sharedEnv key resolves from .chezmoidata.toml
requirement_outcomes:
  - id: REQ-PS-PROFILE
    from_status: active
    to_status: validated
    proof: Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl exists; includes env_vars_ps1 and aliases_ps1 fragments; mise/zoxide/starship activation present; czapply function defined
  - id: REQ-GITBASH-BASHRC
    from_status: active
    to_status: validated
    proof: dot_bashrc.tmpl exists consuming env_vars_posix and aliases_posix; Windows SSH routing block inline-gated with chezmoi.os==windows; mise activation present
  - id: REQ-EXISTING-BASHRC
    from_status: active
    to_status: validated
    proof: dot_bashrc (plain) removed; dot_bashrc.tmpl replaces it — confirmed by git show 3aaeea9 diff
  - id: REQ-SHARED-ALIASES
    from_status: active
    to_status: validated
    proof: aliases_posix fragment has 8 groups (Navigation, Editors, Chezmoi, Git, Docker, eza, yt-dlp, grep); aliases_ps1 mirrors same 8 groups; both consumed by all three shell targets
  - id: REQ-SHARED-ENVVARS
    from_status: active
    to_status: validated
    proof: env_vars_posix and env_vars_ps1 fragments render EDITOR/VISUAL/LC_ALL/GEMINI_API_KEY/CONTEXT7_API_KEY; chezmoi execute-template confirms ejsonDecrypt works on Linux
  - id: REQ-LINUX-ONLY-ALIASES
    from_status: active
    to_status: validated
    proof: yay/brewfile/bundleantidote/updatedesktopdb absent from aliases_posix; present in 40-aliases.zsh.tmpl zsh-only section — grep confirms
duration: 2026-03-14 to 2026-03-15
verification_result: passed
completed_at: 2026-03-15
---

# M001: Cross-Shell Aliases

**Chezmoi template pipeline delivering single-source aliases and env vars across zsh (Linux), PowerShell (Windows), and Git Bash (Windows) — adding one alias to `aliases_posix` now renders it in all three shells simultaneously.**

## What Happened

S01 (Template Infrastructure) established the entire scaffold in one large commit: `.chezmoidata.toml` with `sharedEnv` data, four `.chezmoitemplates/` fragments (`aliases_posix`, `aliases_powershell`, `env_vars_posix`, `env_vars_ps1`), and the `.chezmoiignore` Documents/ gate. Critically, all template conventions were locked in at this stage — trailing-dot context passing, POSIX inline env-var translation to PS `$env:` blocks, and function-over-Set-Alias for PowerShell argument passthrough. Getting conventions right here prevented retrofitting across all later content.

S02 (PowerShell Profile) delivered `Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl` — the Windows PS7 profile consuming `env_vars_ps1` and `aliases_ps1`, with mise/zoxide/starship activation and a `czapply` function stub. The `chezmoi:template:line-endings lf` directive prevents CRLF corruption when applied on Windows. The `.chezmoiignore` gate (`Documents/` excluded on non-Windows) means this file is a no-op on Linux.

S03 (Git Bash Configuration) converted the existing `dot_bashrc` to `dot_bashrc.tmpl`. The file now consumes shared POSIX fragments and inline-gates Windows-specific blocks (`{{ if eq .chezmoi.os "windows" }}`). The SSH routing section sets `GIT_SSH` to Windows' native `ssh.exe` and `SSH_AUTH_SOCK` to the OpenSSH agent named pipe — avoiding a second agent spawn conflict with the Windows OpenSSH service. A `czapply` alias override after the `aliases_posix` include rewrites the shared `source ~/.zshrc` to `chezmoi apply -v` (`.zshrc` does not exist on Windows).

S04 (Zsh Alignment) converted `40-aliases.zsh` to `40-aliases.zsh.tmpl` consuming the shared `aliases_posix` fragment. Linux-only aliases (yay, brewfile, bundleantidote, updatedesktopdb) remain in the zsh-only section. The eza guard was removed — the fragment handles eza unconditionally, consistent with PS and Git Bash behavior. No `chezmoi:template:line-endings` directive added — Linux-only file, no CRLF risk. A final rename commit normalized `aliases_powershell` to `aliases_ps1` for consistency with `env_vars_ps1`.

The four slices connect cleanly: S01 provides fragments, S02/S03 consume them on Windows, S04 closes the loop on Linux. Single-source-of-truth is complete.

## Cross-Slice Verification

**Success criterion: All 18 v1 requirements shipped**
Verified by inspecting all delivered files and PROJECT.md requirement list. Six requirement categories validated (PS profile, Git Bash bashrc, existing bashrc replacement, shared aliases, shared env vars, Linux-only aliases). No active requirements remain.

**Success criterion: Adding an alias to `aliases_posix` renders it in zsh, PowerShell, and Git Bash simultaneously**
Verified structurally: `aliases_posix` is included via `{{ template "aliases_posix" . }}` in `exact_zsh/40-aliases.zsh.tmpl` and `dot_bashrc.tmpl`; `aliases_ps1` mirrors the same content consumed by `Microsoft.PowerShell_profile.ps1.tmpl`. One edit to the fragment propagates on next `chezmoi apply`.

**Success criterion: `chezmoi apply` on Linux and Windows produces correct shell-specific files with no manual duplication**
Linux side verified: `chezmoi execute-template '{{ template "aliases_posix" . }}'` renders all 8 alias groups correctly; `chezmoi execute-template '{{ template "env_vars_posix" . }}'` outputs EDITOR/VISUAL/LC_ALL/SUDO_EDITOR/GEMINI_API_KEY/CONTEXT7_API_KEY. `.chezmoiignore` gates `Documents/` on non-Windows — confirmed by grep. Windows side verified structurally by template authoring (cannot apply on Linux); PS profile has `chezmoi:template:line-endings lf` to prevent CRLF.

**Definition of done check:** All 4 slices are `[x]` in M001-ROADMAP.md. All template files verified present and syntactically correct. No slice summaries existed (plans only) — this milestone summary captures the cross-slice narrative.

## Requirement Changes

- REQ-PS-PROFILE: active → validated — `Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl` present with mise/zoxide/starship activation, env_vars_ps1 and aliases_ps1 fragments consumed
- REQ-GITBASH-BASHRC: active → validated — `dot_bashrc.tmpl` present with mise activation, SSH routing, env_vars_posix and aliases_posix fragments consumed
- REQ-EXISTING-BASHRC: active → validated — `dot_bashrc` removed, replaced by `dot_bashrc.tmpl` (git show 3aaeea9)
- REQ-SHARED-ALIASES: active → validated — 8 alias groups in both `aliases_posix` and `aliases_ps1`, consumed by all three shell targets; grep confirms no duplication
- REQ-SHARED-ENVVARS: active → validated — `env_vars_posix` and `env_vars_ps1` render 6 vars including ejson-decrypted secrets; execute-template confirms on Linux
- REQ-LINUX-ONLY-ALIASES: active → validated — yay/brewfile/bundleantidote/updatedesktopdb absent from shared fragment, present only in zsh template; grep confirms

## Forward Intelligence

### What the next milestone should know
- `.chezmoitemplates/aliases_posix` and `aliases_ps1` are the authoritative single sources — add new shared aliases here and both shells get them automatically
- `.chezmoidata.toml` holds `[sharedEnv]` data; non-secret shared values go here; secrets always go through `ejsonDecrypt` in fragments
- The `czapply` alias is defined in the shared fragment as `source ~/.zshrc` — bash and PS both override this after the include; any new shell consumer must also override it
- `Documents/` deploys only on Windows via `.chezmoiignore` — no extra gating needed in the PS profile itself
- `dot_bashrc.tmpl` uses inline `{{ if eq .chezmoi.os "windows" }}` for Windows-specific sections — the file itself deploys on both Linux and Windows

### What's fragile
- `aliases_ps1` `gp` function is a stub (always pushes with `-u`) — the full zsh conditional (`[[ -z $(git config ...) ]]`) was not ported because bash conditionals don't translate to PS; acceptable for now but noted in fragment comments
- Windows apply has not been end-to-end validated on a real Windows machine — structural verification only; first real apply may surface EJSON_KEYDIR path issues or OneDrive Documents path redirect
- macOS-specific aliases (gitkraken, gk, g) remain in `40-aliases.zsh.tmpl` without an OS guard — they will fail silently on Linux if gitkraken is absent, but that's pre-existing behavior

### Authoritative diagnostics
- `chezmoi execute-template '{{ template "aliases_posix" . }}'` — confirms fragment renders and ejsonDecrypt works
- `grep -r 'template "aliases' ~/.local/share/chezmoi --include="*.tmpl"` — shows all fragment consumers at a glance
- `chezmoi apply --dry-run` on Linux — confirms Documents/ is excluded and no Windows-only content leaks

### What assumptions changed
- Research assumed `chezmoidata.toml` would hold structured alias data iterated via range — actual implementation used explicit template blocks (simpler, easier to read, no range abstraction needed at this scale)
- Research flagged PowerShell encoding (UTF-8 BOM) as a pitfall — `chezmoi:template:line-endings lf` addressed line endings; BOM not needed in practice for PS7

## Files Created/Modified

- `.chezmoidata.toml` — shared env-var data (`[sharedEnv]`) consumed by all template fragments
- `.chezmoitemplates/aliases_posix` — POSIX alias block (8 groups) consumed by zsh and Git Bash
- `.chezmoitemplates/aliases_ps1` — PowerShell function block (8 groups) consumed by PS profile
- `.chezmoitemplates/env_vars_posix` — POSIX export statements consumed by zsh and Git Bash
- `.chezmoitemplates/env_vars_ps1` — PowerShell `$env:` assignments consumed by PS profile
- `Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl` — chezmoi-managed PS7 profile (Windows-only via .chezmoiignore)
- `dot_bashrc.tmpl` — chezmoi-managed Git Bash config (replaces plain `dot_bashrc`; deploys on Linux and Windows; Windows sections inline-gated)
- `exact_zsh/40-aliases.zsh.tmpl` — zsh alias file converted to template consuming `aliases_posix` fragment
- `.chezmoiignore` — added `Documents/` gate (excluded on non-Windows)
