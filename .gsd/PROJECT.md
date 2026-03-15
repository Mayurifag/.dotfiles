# Cross-Shell Shared Configuration

## What This Is

A cross-shell configuration sharing system within the chezmoi dotfiles repo. Uses chezmoi templates to generate shell-specific files (PowerShell profile, Git Bash `.bashrc`, and zsh aliases) from shared definitions, so aliases and env vars are defined once and rendered in the correct syntax for each target shell. Covers zsh (Linux), PowerShell (Windows), and Git Bash (Windows). **All milestones complete — M001 through M005-6h5649 shipped.**

## Core Value

Aliases and environment variables are defined in one place and automatically rendered in the correct syntax for each shell — no drift between environments.

## Requirements

### Validated

- ✓ Chezmoi-managed PowerShell profile: mise activation + zoxide + starship + shared aliases (as PS functions) + shared env vars — Phase 2
- ✓ Chezmoi-managed Git Bash `.bashrc`: mise activation + ssh-agent setup + shared aliases (POSIX syntax) + shared env vars — Phase 3
- ✓ Existing `dot_bashrc` replaced/integrated with the new Git Bash config — Phase 3 (renamed to `dot_bashrc.tmpl`)
- ✓ Shared alias groups rendered per-shell via chezmoi templates (Navigation, Git, Docker, Chezmoi, Editor, eza, yt-dlp, grep) — Phases 1–4
- ✓ Shared env vars rendered per-shell via chezmoi templates (EDITOR/VISUAL, LC_ALL, GEMINI_API_KEY via ejson, PATH additions) — Phases 1–3
- ✓ Linux-specific aliases (yay, brewfile, bundleantidote, updatedesktopdb) remain zsh-only — not shared — Phase 4
- ✓ `gk` function and `g` alias in PowerShell profile: launches GitKraken at git root, non-blocking, with guard clauses — M003-f3vdyg
- ✓ `gp` in PowerShell conditionally sets upstream (no stub); `free` function shows memory in MB; `czapply` auto-re-sources `$PROFILE` — M005-6h5649

### Active

None — all requirements validated.

### Out of Scope

- Modifying existing zsh config files (beyond extracting shared alias data) — zsh works fine today
- zoxide and starship for Git Bash — Git Bash on Windows is used minimally (Claude only)
- Windows system env var management outside of shell profiles — handled by chezmoi-managed files
- ejson setup on Windows — assumed to already work; no fallback mechanism needed

## Context

- Repo: `~/.local/share/chezmoi` (this repo)
- Existing zsh setup: `exact_zsh/` directory with numbered files (`00-managers.zsh` through `90-software.zsh`)
- Aliases live in: `exact_zsh/40-aliases.zsh.tmpl` (chezmoi-managed template consuming `aliases_posix` fragment)
- Env vars live in: `exact_zsh/20-exports.zsh.tmpl` (templated with ejson for API keys)
- Shared alias fragment: `.chezmoitemplates/aliases_posix` — consumed by zsh, PS, and Git Bash
- Mise in zsh: activated via `wintermi/zsh-mise` antidote plugin
- Windows setup: PowerShell profile and Git Bash `.bashrc` tracked by chezmoi (via `windows/` and `dot_bashrc.tmpl`)
- Chezmoi templating: uses `{{ .chezmoi.os }}` for OS conditions, ejson decryption via `ejsonDecrypt`

## Constraints

- **Syntax**: PowerShell aliases require `function`/`Set-Alias` syntax; Git Bash uses POSIX `alias` — must be generated separately
- **OS targeting**: PowerShell profile only deployed on Windows; Git Bash `.bashrc` only on Windows; chezmoi OS conditions required
- **Secrets**: GEMINI_API_KEY (and any future API keys) use ejson decryption — same approach as existing `20-exports.zsh.tmpl`
- **Non-destructive**: Existing zsh config must keep working unchanged

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Chezmoi templates generate per-shell files | Single place to add aliases/vars; no runtime parsing overhead; idiomatic for this repo | Validated — Phases 1–4 |
| Git Bash gets no zoxide/starship | Git Bash used only for Claude on Windows — minimal setup preferred | Validated — Phase 3 |
| Reuse existing `dot_bashrc` as base for Git Bash config | Already has mise activation, avoids creating new file from scratch | Validated — Phase 3 |
| dot_bashrc.tmpl uses internal OS conditions, not .chezmoiignore | File deploys on both Linux and Windows; Windows blocks inline-gated with `{{ if eq .chezmoi.os "windows" }}` | Validated — Phase 3 |
| czapply override after aliases_posix fragment | Shared fragment defines czapply with `source ~/.zshrc`; bash overrides to `chezmoi apply -v` (no .zshrc on Windows) | Validated — Phase 3 |
| SSH routing via GIT_SSH + SSH_AUTH_SOCK, no socat/npiperelay | Point GIT_SSH to Windows native ssh.exe; reads named pipe directly; zero new dependencies | Validated — Phase 3 |
| eza guard removed from zsh template (unconditional) | Fragment already handles eza unconditionally; guard was inconsistent with PS/Git Bash behavior | Validated — Phase 4 |
| No line-endings directive in 40-aliases.zsh.tmpl | Linux-only deployment; directive only needed for Windows-deployed templates | Validated — Phase 4 |
| dot_config/mise/config.toml.tmpl OS-gates conditional-launcher (D014) | conditional-launcher is Linux-only; D009's plain-TOML rationale applied only to claude-code (cross-platform) | Validated — M004-fqlkfh |

---
*Last updated: 2026-03-15 after M005-6h5649*

## Milestone Sequence

- **M001** — Cross-Shell Aliases ✓ complete
- **M002-77v01s** — Cross-Platform Claude Code via Mise ✓ complete
- **M003-f3vdyg** — GitKraken PS Alias ✓ complete
- **M004-fqlkfh** — Mise Config OS Gating ✓ complete
- **M005-6h5649** — PowerShell Alias Parity ✓ complete

## Recent Hotfixes

- 2026-03-15: `dot_config/yakuakerc` — swapped `Ctrl+W` to `close-session` (was `close-active-terminal`; `Alt+W` now closes split pane)
- 2026-03-15: `dot_config/private_konsolerc` — added to chezmoi; fixed `DefaultProfile` pointing at nonexistent `ZSH profile.profile` → `zsh.profile`
- 2026-03-15: `dot_local/share/konsole/shortcuts/Default` — added to chezmoi (was live-only; keybindings lost on fresh machine)
