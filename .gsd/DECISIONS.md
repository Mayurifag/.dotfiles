# Decisions

<!-- Append-only register of architectural and pattern decisions -->

| ID | Decision | Rationale | Date |
|----|----------|-----------|------|
| D001 | Chezmoi templates generate per-shell config files at apply time | Single place to add aliases/vars; no runtime parsing overhead; errors surface at apply time not during interactive sessions; idiomatic for this repo | 2026-03-14 |
| D002 | Git Bash gets no zoxide/starship | Git Bash on Windows is used minimally (Claude only) — minimal setup preferred; avoids unnecessary dependency weight | 2026-03-14 |
| D003 | Reuse existing `dot_bashrc` as base for Git Bash config | Already has mise activation; avoids creating new file from scratch; rename to `.tmpl` is non-destructive | 2026-03-14 |
| D004 | `dot_bashrc.tmpl` uses internal OS conditions, not `.chezmoiignore` | File deploys on both Linux and Windows; Windows-specific blocks inline-gated with `{{ if eq .chezmoi.os "windows" }}`; Linux bashrc stays clean | 2026-03-14 |
| D005 | `czapply` override after `aliases_posix` fragment | Shared fragment defines `czapply` as `source ~/.zshrc`; bash template overrides to `chezmoi apply -v` after include because `.zshrc` does not exist on Windows | 2026-03-14 |
| D006 | SSH routing via `GIT_SSH` + `SSH_AUTH_SOCK` named pipe, no socat/npiperelay | Point `GIT_SSH` to Windows native `ssh.exe`; reads `//./pipe/openssh-ssh-agent` directly; zero new dependencies; avoids second agent conflict | 2026-03-14 |
| D007 | `eza` guard removed from `40-aliases.zsh.tmpl` (unconditional include) | `aliases_posix` fragment already handles eza unconditionally; having a guard only in the zsh consumer was inconsistent with PS/Git Bash behaviour | 2026-03-14 |
| D008 | No `chezmoi:line-endings` directive in `40-aliases.zsh.tmpl` | Linux-only deployment; line-endings directive only needed for Windows-deployed `.tmpl` files to prevent CRLF corruption | 2026-03-14 |
| D009 | `dot_config/mise/config.toml` stays plain TOML (no `.tmpl` rename) for M002-77v01s | `claude-code = "latest"` works on both Linux (aqua backend) and Windows (npm fallback) — mise selects backend automatically; no OS-conditional logic needed in the config file | 2026-03-15 |
| D010 | Use a `run_once` chezmoi script (not `.chezmoiignore` gating) to remove old claude install | run_once scripts execute during `chezmoi apply` before the user runs `mise install`, eliminating the symlink conflict window; `rm -f` / `rm -rf` are safe if targets are already absent | 2026-03-15 |
| D011 | Single slice for M002-77v01s (config + run_once + doc update together) | All three changes are small, low-risk, and converge on one demoable outcome; splitting would add ceremony without value | 2026-03-15 |
| D012 | Use `-p` flag (not `--path`) for GitKraken in PS `gk` function | The zsh alias uses `-p` and is confirmed working; `-p` is the safe choice even if `--path` also works | 2026-03-15 |
| D013 | Single slice for M003-f3vdyg (gk function + g alias in one pass) | Entire milestone is ~10 lines appended to a single file; decomposing further adds ceremony without value | 2026-03-15 |
| D014 | Rename `dot_config/mise/config.toml` → `.toml.tmpl` and OS-gate `conditional-launcher` (supersedes D009 for this entry) | `conditional-launcher` is Linux-only; installing on Windows via mise fails or no-ops; D009 kept config plain because `claude-code` was cross-platform — that rationale doesn't apply to `conditional-launcher` | 2026-03-15 |
| D015 | Single slice for M004-fqlkfh (rename + conditional in one pass) | One-file change with two inseparable steps (rename + edit); splitting adds ceremony without value | 2026-03-15 |
| D016 | Single slice for M005-6h5649 (gp + free + czapply in one pass) | Three small, independent edits across two files; all low-risk with no cross-dependencies; decomposing further adds ceremony without value | 2026-03-15 |
| D017 | `czapply` uses semicolon (not `&&`) to sequence apply + re-source | `. $PROFILE` runs regardless of apply exit code — intentional; mirrors POSIX spirit and avoids silent failure on profile reload when apply partially succeeds | 2026-03-15 |
| D018 | `[int]` truncation (not `[Math]::Round`) for KB→MB in `free` function | Simpler and sufficient for memory display; integer MB values match `free -m` output style; rounding precision not needed for a status display | 2026-03-15 |
