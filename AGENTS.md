# AGENTS.md

**Never edit rendered files.** Edit repo sources.

| Target                              | Source                                          |
| ----------------------------------- | ----------------------------------------------- |
| `~/.config/git/hooks/post-checkout` | `dot_config/git/hooks/executable_post-checkout` |
| `~/.gitconfig`                      | `dot_gitconfig.tmpl`                            |
| `~/.zshrc`                          | `dot_zshrc.tmpl`                                |
| `run_*` scripts                     | `run_*` in repo                                 |

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

## CROSS-PLATFORM

- Keep Arch/MacOS/Win11 same where possible
- Windows: `pwsh.exe` (PS 7), never `powershell.exe` (PS 5)
- Check both `.chezmoitemplates/env_vars_ps1` and `env_vars_posix`. Same for aliases.
