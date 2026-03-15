# M001: Cross-Shell Aliases

**Vision:** A cross-shell configuration sharing system within the chezmoi dotfiles repo — aliases and env vars defined once in chezmoi templates, rendered correctly for zsh (Linux), PowerShell (Windows), and Git Bash (Windows) with no drift between environments.

## Success Criteria

- All 18 v1 requirements shipped
- Adding an alias to `aliases_posix` renders it in zsh, PowerShell, and Git Bash simultaneously
- `chezmoi apply` on Linux and Windows produces correct shell-specific files with no manual duplication

## Slices

- [x] **S01: Template Infrastructure** `risk:medium` `depends:[]`
  > After this: `.chezmoidata.toml`, `.chezmoiignore` (Documents/ gate), and all `.chezmoitemplates/` fragments exist with correct conventions — every downstream shell file can be authored without structural mistakes
- [x] **S02: PowerShell Profile** `risk:medium` `depends:[S01]`
  > After this: chezmoi-managed `Microsoft.PowerShell_profile.ps1` deploys on Windows with mise/zoxide/starship activation, shared env vars, and all alias groups as PS functions
- [x] **S03: Git Bash Configuration** `risk:medium` `depends:[S02]`
  > After this: chezmoi-managed `dot_bashrc.tmpl` gives Git Bash on Windows mise activation, Windows OpenSSH SSH routing, shared env vars, and all shared alias groups
- [x] **S04: Zsh Alignment** `risk:medium` `depends:[S03]`
  > After this: `40-aliases.zsh.tmpl` consumes the shared `aliases_posix` fragment — single-source-of-truth complete across all three shells
