# Project Rules — chezmoi dotfiles repo

## Cross-platform compatibility

- Keep systems (Arch/MacOS/Win11) same where possible. Example: adding/changing alias? Check all locations (e.g. env vars: `.chezmoitemplates/env_vars_ps1` and `.chezmoitemplates/env_vars_posix`)
- Windows: Always use `pwsh.exe` (PowerShell 7), never `powershell.exe` (legacy PS 5)

## Chezmoi file naming

- `dot_foo` → `~/.foo` (e.g. `dot_npmrc` → `~/.npmrc`)
- `dot_config/` → `~/.config/`
- `.tmpl` suffix → treated as Go template

## Dotfiles workflow

- This is chezmoi source dir. All persistent changes to shell config, aliases, profiles MUST go here, not rendered files at target locations (e.g. `~/Documents/PowerShell/Microsoft.PowerShell_profile.ps1`)
- After editing source files, run `timeout 3 chezmoi diff` as canary — completes = safe to run `timeout 3 chezmoi apply -v`. Either times out = tell user to run `czapply` manually (chezmoi waiting for interactive input)
