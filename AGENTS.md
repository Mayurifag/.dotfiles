# AGENTS.md

**Never edit files in their real paths.** Edit repo sources and apply. Examples:

| Target                              | Source                                          |
| ----------------------------------- | ----------------------------------------------- |
| `~/.config/git/hooks/post-checkout` | `dot_config/git/hooks/executable_post-checkout` |
| `~/.gitconfig`                      | `dot_gitconfig.tmpl`                            |
| `~/.zshrc`                          | `dot_zshrc.tmpl`                                |
| `run_*` scripts                     | `.chezmoiscripts/{posix,macos,linux,windows}/`  |

Global package list files in `install/` are intended to be authoritative; `make mise-packages` should remove leftover
globals not present in the corresponding list.

`chezmoi apply` renders source → target. Target edits vanish.

## CONVENTIONS (from chezmoi)

- `dot_foo` → `~/.foo`
- `dot_config/` → `~/.config/`
- `.tmpl` → Go template
- `executable_` → `+x`
- `run_once_` / `run_after_` → run by `chezmoi apply`

## VERIFY EDITS

```bash
timeout 3 chezmoi diff
timeout 3 chezmoi apply -v
```

`timeout` fires → chezmoi waits for input. Tell user run `czapply` manually.

## AGENT BEHAVIOR

- Keep legacy code cleanup leftovers short. Assume one user/app state; if one cleanup was done once, that is enough.
  Mention repeat cleanup as a consideration in the summary and ask before adding it.

## CROSS-PLATFORM

- Keep Arch/MacOS/Win11 same where possible
- Windows: `pwsh.exe` (PS 7), never `powershell.exe` (PS 5)
- Windows MinGW: install WinLibs with `winget install --id BrechtSanders.WinLibs.POSIX.UCRT --exact --silent --disable-interactivity --accept-package-agreements --accept-source-agreements`; do not use MSYS2 `pacman` for MinGW.
- Check both `.chezmoitemplates/env_vars_ps1` and `env_vars_posix`. Same for aliases.

## OPENCODE

- Put agent reasoning profiles in agent `variant`, not direct provider option fields.
- User does not use LSP; keep OpenCode LSP disabled/hidden unless asked otherwise.

## SCRIPTS

- Python is available on every target system; prefer it for nontrivial cross-platform alias utilities when compilation is not desired.
