# Project Rules — chezmoi dotfiles repo

## Cross-platform compatibility

- Have my systems (Arch/MacOS/Win11) work the same way if possible. If user wants to add/change alias, think if there
  are several places for that (e.g. for env vars `.chezmoitemplates/env_vars_ps1` and
  `.chezmoitemplates/env_vars_posix` exist)

## Windows shell

- Always use `pwsh.exe` (PowerShell 7), never `powershell.exe` (legacy PS 5)

## Chezmoi file naming

- `dot_foo` → `~/.foo` (e.g. `dot_npmrc` → `~/.npmrc`)
- `dot_config/` → `~/.config/`
- `.tmpl` suffix → treated as a Go template

## Dotfiles workflow

- This is the chezmoi source directory. All persistent changes to shell config, aliases, and profiles MUST be made
  here, not to the rendered files in their target locations
  (e.g. `~/Documents/PowerShell/Microsoft.PowerShell_profile.ps1`)
- After editing source files, first run `timeout 3 chezmoi diff` as a canary — if it completes, secrets are already
  unlocked and it's safe to run `timeout 3 chezmoi apply -v`. If either times out, tell the user to run `czapply`
  manually (chezmoi is waiting for interactive input, e.g. password/secret decryption)
