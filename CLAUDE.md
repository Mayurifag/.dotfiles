# Project Rules — chezmoi dotfiles repo

## Windows shell

- Always use `pwsh.exe` (PowerShell 7), never `powershell.exe` (legacy PS 5).

## Dotfiles workflow

- This is the chezmoi source directory. All persistent changes to shell config, aliases, and profiles MUST be made here, not to the rendered files in their target locations (e.g. `~/Documents/PowerShell/Microsoft.PowerShell_profile.ps1`).
- After editing source files, run `chezmoi apply -v` with a timeout (e.g. `timeout 15 chezmoi apply -v`) to render and deploy the changes.
  Use a timeout because chezmoi may prompt for interactive input (e.g. password/secret decryption) and hang indefinitely without one.
  If it times out, tell the user to run `czapply` manually.
- Key source locations:
  - Shell aliases (PowerShell): `.chezmoitemplates/aliases_ps1`
  - Shell aliases (POSIX/zsh): `.chezmoitemplates/aliases_posix` or `exact_zsh/`
  - PowerShell profile: `Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl`
