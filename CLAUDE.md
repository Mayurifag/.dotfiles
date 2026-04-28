# Project Rules — chezmoi dotfiles repo

## Dotfiles workflow

- This is chezmoi source dir. All persistent changes to shell config, aliases, software, profiles MUST go here, not rendered files at target locations (e.g. `~/Documents/PowerShell/Microsoft.PowerShell_profile.ps1`)
- After editing source files, run `timeout 3 chezmoi diff` as canary — completes = safe to run `timeout 3 chezmoi apply -v`. Either times out = tell user to run `czapply` manually (chezmoi waiting for interactive input)

## Cross-platform compatibility

- Keep systems (Arch/MacOS/Win11) same where possible. Example: adding/changing alias? Check all locations (e.g. env vars: `.chezmoitemplates/env_vars_ps1` and `.chezmoitemplates/env_vars_posix`)
- Windows: Always use `pwsh.exe` (PowerShell 7), never `powershell.exe` (legacy PS 5)

## Chezmoi file naming

- `dot_foo` → `~/.foo` (e.g. `dot_npmrc` → `~/.npmrc`)
- `dot_config/` → `~/.config/`
- `.tmpl` suffix → treated as Go template

## Run scripts & .chezmoiignore

- Scripts at repo root named `run_after_X.ps1` / `run_once_after_X.ps1` execute on every (or first) `chezmoi apply`
- For ignore purposes, chezmoi matches scripts by target name = filename **with the `run_*_` prefix stripped**. Example: `run_after_backup.ps1` → ignore entry `backup.ps1`
- When adding/renaming a platform-specific script, update `.chezmoiignore` under the matching `{{ if ne .chezmoi.os "<os>" }}` guard so other OSes skip it
- `windows/` directory is unconditionally ignored — safe place for Windows-only manual scripts and config snapshots (Windhawk, PowerToys, etc.). No per-file ignore work needed for files inside it

## Aliases

- Simple aliases (single command + args, no conditionals) → `.chezmoidata.toml` under `[sharedAliases.<Category>]`
- Use `cmd` for shared command; add `ps_cmd` when Windows needs a different invocation (e.g. `NUL` vs `/dev/null`)
- Template renders POSIX as `alias name='cmd'` and PS1 as `function name { cmd @args }`
- Complex functions (conditionals, multi-step, platform-specific) stay in `.chezmoitemplates/aliases_posix` and `aliases_ps1`
