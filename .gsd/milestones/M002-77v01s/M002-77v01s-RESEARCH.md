# M002-77v01s — Research

**Date:** 2026-03-15

## Summary

The codebase is well-prepared for this milestone. The fragment infrastructure (`aliases_posix`, `aliases_ps1`) established in M001 provides a direct pattern to clone for `functions_posix` and `functions_ps1`. The seven shared functions (`c`, `q`, `mkcd`, `gcd`, `grom`, `dec`, `enc`) all live in `exact_zsh/30-commands.zsh` today and can be cleanly extracted with minor portability fixes — primarily swapping `[[ ]]` for `[ ]` where needed (though `[[` works in bash/zsh; the real constraint is avoiding zsh-isms) and translating inline env-var prefixes (`LEFTHOOK=0 git`) to PowerShell's `$env:` pattern already used in `aliases_ps1`.

The main implementation tasks are: (1) create the two new template fragments, (2) convert `exact_zsh/30-commands.zsh` → `30-commands.zsh.tmpl` and inject `{{ template "functions_posix" . }}`, (3) add the same include to `dot_bashrc.tmpl`, and (4) add `{{ template "functions_ps1" . }}` to the PS profile template. One structural pitfall: `if_command_exists` is defined in `30-commands.zsh` and is only sourced by zsh — the `functions_posix` fragment must either re-define this helper inline or inline `command -v` checks directly. The PowerShell fragment needs `New-TemporaryFile` (or `[System.IO.Path]::GetTempFileName()`) in place of `mktemp`, and must follow the `$env:LEFTHOOK = "0"; ...; Remove-Item Env:LEFTHOOK` pattern for env-prefixed commands, consistent with `aliases_ps1`.

Slice ordering is clear: do the zsh side first (rename + wire template), verify `chezmoi apply` is clean, then add bash consumer, then PS fragment. Each step is independently verifiable via `chezmoi execute-template`.

## Recommendation

Follow the `aliases_posix` / `aliases_ps1` clone-and-adapt approach exactly. Do not invent new abstractions — the pattern is proven and the chezmoi template system handles everything. The only non-trivial work is the PowerShell translation of `dec` (temp file) and `grom` (branch detection + `LEFTHOOK` env-var prefix).

For `if_command_exists` in the POSIX fragment: define a local version at the top of `functions_posix`. It's a two-liner and self-contained — no cross-fragment dependency needed.

## Don't Hand-Roll

| Problem | Existing Solution | Why Use It |
|---------|------------------|------------|
| Per-shell function rendering | `.chezmoitemplates/` fragment system + `{{ template "name" . }}` includes | Already working for aliases and env_vars; zero new infrastructure |
| POSIX portability helper | `command -v "$1" >/dev/null 2>&1` one-liner | No external dependency; works in bash and zsh; can define `_cmd_exists` at top of fragment |
| PowerShell env-var prefix for commands | `$env:VAR = "val"; ...; Remove-Item Env:VAR` pattern | Already used for `LEFTHOOK` in `grc`, `gpf`, `gri`, `qwe` in `aliases_ps1` — exact pattern to copy |
| PowerShell temp file | `New-TemporaryFile` cmdlet | Built into PS — returns a `FileInfo` object; use `.FullName` for path |
| Line endings on Windows templates | `{{- /* chezmoi:template:line-endings lf */ -}}` directive | Already present in `dot_bashrc.tmpl` and PS profile template; `30-commands.zsh.tmpl` is Linux-only, no directive needed (D008) |

## Existing Code and Patterns

- `exact_zsh/30-commands.zsh` — source of all shared functions; rename to `.tmpl`, inject `{{ template "functions_posix" . }}` in place of the 7 shared functions; everything else stays inline
- `.chezmoitemplates/aliases_posix` — structural template for `functions_posix`; header comment format, include instructions, section grouping with `## Label` comments
- `.chezmoitemplates/aliases_ps1` — structural template for `functions_ps1`; PS function syntax, `$env:` env-var prefix/cleanup pattern (lines for `grc`, `gpf`), `@args` for pass-through
- `dot_bashrc.tmpl` — add `{{ template "functions_posix" . }}` after the existing `{{ template "aliases_posix" . }}` line; keep the `czapply` override below
- `Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl` — add `{{ template "functions_ps1" . }}` after `{{ template "aliases_ps1" . }}`; the `czapply` override follows

### Portability notes per function

| Function | POSIX fragment | PS fragment |
|----------|---------------|-------------|
| `if_command_exists` helper | Define `_cmd_exists() { command -v "$1" >/dev/null 2>&1; }` at top of fragment | PS: `function Test-Command { param($n) (Get-Command $n -EA SilentlyContinue) -ne $null }` |
| `mkcd` | `[ -n "$1" ] && mkdir -p "$@" && builtin cd "$1"` — works as-is in bash+zsh | `function mkcd { param($p) New-Item -Type Directory -Force $p; Set-Location $p }` |
| `gcd` | `git clone --recurse-submodules && builtin cd $(basename)` — works in bash | `git clone --recurse-submodules; Set-Location (Split-Path -Leaf $args[0] -replace '\.git$')` |
| `grom` | Works as-is; uses only POSIX conditionals and `git` | Must use `$env:LEFTHOOK = "0"` prefix + cleanup; branch detection via `git rev-parse` same logic |
| `dec` | Replace `[[ -f ]]` → `[ -f ]`; `local tmp_file=$(mktemp)` works in bash | Use `$tmp = New-TemporaryFile`; `ejson decrypt` piped/redirected; `Move-Item` for atomic replace |
| `enc` | Works as-is; replace `[[ -f ]]` → `[ -f ]` | Straightforward PS translation |
| `q` | Replace `if_command_exists` with `_cmd_exists`; `unalias q 2>/dev/null` stays in consumer (`30-commands.zsh.tmpl`) not fragment | `Test-Command` guard; no unalias needed in PS |
| `c` | `IS_SANDBOX=1 claude "$@"` — env-var prefix works in bash | `$env:IS_SANDBOX = "1"; claude --dangerously-skip-permissions @args; Remove-Item Env:IS_SANDBOX` |

### Fragment header issue — `unalias` guards

`unalias q 2>/dev/null` and `unalias c 2>/dev/null` are in `30-commands.zsh` to unset any alias before defining the function. These should stay **in `30-commands.zsh.tmpl`** (zsh context) not in `functions_posix` — bash `.bashrc` doesn't set these aliases. Alternatively keep them in the fragment prefixed with `unalias q 2>/dev/null; unalias c 2>/dev/null` — both bash and zsh handle `unalias` with `2>/dev/null` safely.

## Constraints

- `functions_posix` must be POSIX-bash-compatible — no zsh-isms (`read "var?prompt"`, `typeset -a`, `${array[@]}` zsh-style exprs). Git Bash is bash 4.x; `[[`, `local`, `command -v`, `builtin cd` all work.
- `exact_zsh/30-commands.zsh` → `30-commands.zsh.tmpl` rename: chezmoi tracks the file by source name; renaming the source file (adding `.tmpl`) converts it from a plain-copy to a template. No chezmoi commands needed — just rename and add the template directive-less include.
- PS profile template already has `{{- /* chezmoi:template:line-endings lf */ -}}` — `functions_ps1` content will inherit LF endings automatically through the parent template.
- `if_command_exists` is not available in bash (it's only defined in `30-commands.zsh`). The fragment must be self-contained.
- `mktemp` is not available in PowerShell — use `New-TemporaryFile`.
- `chezmoi execute-template` is the fast verification loop; no `chezmoi apply` needed to validate template rendering.

## Common Pitfalls

- **`if_command_exists` not in bash scope** — functions_posix must define its own command-existence helper or inline `command -v` checks. Reusing the name `if_command_exists` would work but could shadow the zsh version; naming it `_cmd_exists` avoids collision.
- **`[[ ]]` in functions_posix** — `dec`/`enc` use `[[ -f ]]`; converting to `[ -f ]` is safe for both bash and zsh and avoids accidental zsh-ism creep.
- **`unalias` in fragment vs consumer** — putting `unalias q 2>/dev/null` in functions_posix is harmless in bash but unnecessary; keeping unalias guards in the fragment is simpler than requiring consumers to prepend them.
- **`grom` LEFTHOOK prefix** — `LEFTHOOK=0 git rebase -i "origin/$GIT_BRANCH"` is valid bash/zsh but not PS. In PS, must split into set-env / command / remove-env — same as `grc` pattern in `aliases_ps1`.
- **`gcd` basename in PS** — PowerShell has no `basename` command; use `Split-Path -Leaf` with a `-replace '\.git$'` to strip the extension.
- **Template include position in `.bashrc`** — the `czapply` alias override must come **after** `{{ template "functions_posix" . }}` (functions may define a czapply-adjacent function); this matches the existing alias ordering.
- **30-commands.zsh rename** — after renaming to `.tmpl`, `chezmoi managed` output changes from `zsh/30-commands.zsh` (plain file) to the same path but chezmoi knows it's a template. The deployed file path doesn't change. Run `chezmoi apply --dry-run` after rename to confirm no unexpected diff.

## Open Risks

- **`yawn`/`yawn-debug` on Windows** — `q` function guards with existence check, so failure is graceful. But no confirmation this tool is actually installed on Windows. Fragment can be written with the guard; user must verify at integration time.
- **`ejson` Windows path** — `windows/INSTRUCTION.md` documents a symlink setup for `~/.ejson` but notes it as manual. `dec`/`enc` guard with `ejson` existence check, so they fail gracefully if not installed. PS fragment should do the same.
- **PS `$env:IS_SANDBOX` cleanup** — if `claude` throws an exception, the `Remove-Item Env:IS_SANDBOX` line might not run in PS. Wrapping in `try/finally` would be safer but adds complexity; document the tradeoff.
- **`chezmoi apply` on Linux** — renaming `30-commands.zsh` → `30-commands.zsh.tmpl` changes it from plain-copy to template. If any template functions are called (e.g., `ejsonDecrypt`) they'll error without the ejson key in place. The current functions don't use chezmoi template functions, so this is low risk.

## Skills Discovered

| Technology | Skill | Status |
|------------|-------|--------|
| chezmoi templates | No dedicated skill — chezmoi docs sufficient | none found |
| PowerShell | No dedicated skill | none found |
