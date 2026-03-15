# M003-f3vdyg — Research

**Date:** 2026-03-15

## Summary

This is a one-file addition to `.chezmoitemplates/aliases_ps1`. The zsh reference in `40-aliases.zsh.tmpl` is clear: `gk` launches GitKraken with `--new-window -p <git-root>` backgrounded, and `g` is an alias for it. The PowerShell equivalent needs three adaptations versus zsh: (1) glob the versioned `app-*` subdir at invocation time to find the exe, (2) use `Start-Process` instead of `& ... &` to truly detach the process, and (3) convert the git root path to a Windows-native path since GitKraken is a Windows native app.

The path conversion is the only subtlety. `git rev-parse --show-toplevel` run from PowerShell with Git for Windows returns `C:/Users/...` (forward slashes, drive letter prefix) — `Resolve-Path` handles this cleanly. The `-l /dev/null` log suppression from the zsh version is unnecessary with `Start-Process` since stdout/stderr are not inherited by default. Omit it.

The implementation is a single `## GitKraken` block appended to `aliases_ps1` — a `gk` function body plus a `Set-Alias -Name g -Value gk` line. No other file changes are required. Risk is low; the only runtime failure mode is GitKraken not being installed (glob returns nothing), which should be surfaced gracefully with an early-return guard.

## Recommendation

Add to the bottom of `.chezmoitemplates/aliases_ps1` (after `## grep`):

```powershell
## GitKraken
function gk {
    $gkExe = Get-Item "$env:LOCALAPPDATA\gitkraken\app-*\gitkraken.exe" -ErrorAction SilentlyContinue |
              Sort-Object Name -Descending |
              Select-Object -First 1 -ExpandProperty FullName
    if (-not $gkExe) { Write-Warning "GitKraken not found"; return }
    $root = git rev-parse --show-toplevel 2>$null
    if (-not $root) { Write-Warning "Not a git repository"; return }
    $root = (Resolve-Path $root).Path
    Start-Process -FilePath $gkExe -ArgumentList "--new-window", "--path", $root
}
Set-Alias -Name g -Value gk
```

`Sort-Object Name -Descending | Select-Object -First 1` picks the newest `app-*` version by lexicographic sort on the directory name (which GitKraken uses as `app-X.Y.Z`).

## Don't Hand-Roll

| Problem | Existing Solution | Why Use It |
|---------|------------------|------------|
| Background process launch | `Start-Process` (built-in) | Truly detaches the process; `&` in PS blocks until the exe exits |
| Newest versioned subdir | `Get-Item ... \| Sort-Object Name -Descending \| Select-Object -First 1` | Glob + sort is the idiomatic PS pattern; no external tools needed |
| Path normalisation | `(Resolve-Path $path).Path` | Converts forward-slash paths from git to backslash Windows paths; handles already-native paths too |

## Existing Code and Patterns

- `.chezmoitemplates/aliases_ps1` — the **only file to change**; all PS aliases follow the `function <name> { ... }` then optional `Set-Alias -Name <short> -Value <name>` pattern; existing `Set-Alias -Name lzg -Value lazygit` under `## Git` is the exact pattern to follow for `g → gk`
- `exact_zsh/40-aliases.zsh.tmpl` — zsh reference: `gitkraken --new-window -p "$(git rev-parse --show-toplevel)"` backgrounded via `eval ... &`; maps to `Start-Process -FilePath $exe -ArgumentList "--new-window", "--path", $root` in PS
- `Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl` — consumes `aliases_ps1` via `{{ template "aliases_ps1" . }}`; no changes needed here
- `.chezmoitemplates/aliases_posix` — does **not** contain `gk`/`g`; they live only in `40-aliases.zsh.tmpl` (zsh-only section); this confirms they are intentionally absent from the shared posix fragment and must be added explicitly to `aliases_ps1`

## Constraints

- **Versioned install path** — `$env:LOCALAPPDATA\gitkraken\app-*\gitkraken.exe` must be globbed at invocation time; no stable single path exists
- **True detach required** — `Start-Process` without `-Wait` launches detached; the `-NoNewWindow` flag is *not* needed (GitKraken is a GUI app, not a console app — it has no inherited console to suppress)
- **Windows path for GitKraken** — GitKraken is a native Electron app; it expects Windows paths (`C:\...` or `C:/...`); `Resolve-Path` produces the canonical form
- **`-l /dev/null` — omit** — this flag instructs GitKraken where to write its log; omitting it uses the default; `Start-Process` does not inherit stdout/stderr anyway, so there is nothing to suppress
- **`Set-Alias` cannot alias a function that takes args** — `Set-Alias -Name g -Value gk` works here because `gk` takes no parameters (no `@args` to forward); this matches the zsh `alias g='gk'` semantics exactly

## Common Pitfalls

- **`Sort-Object Name` vs `Sort-Object LastWriteTime`** — sort by `Name` (version string in dir name); `LastWriteTime` could be unreliable if files were touched post-install. GitKraken version dirs are named `app-X.Y.Z` so lexicographic sort on `Name` is correct for ascending; use `-Descending` + `Select-Object -First 1` for newest.
- **`-NoNewWindow` on a GUI app** — unnecessary and potentially harmful; `Start-Process` on a GUI exe already detaches without it; adding it would attempt to run GitKraken in the current console window (not what we want).
- **Forgetting `-ErrorAction SilentlyContinue` on `Get-Item` glob** — if `app-*` matches nothing (GitKraken not installed), `Get-Item` throws by default; the flag makes it return `$null` so the guard `if (-not $gkExe)` can handle it cleanly.
- **`Resolve-Path` on a non-existent path** — only call `Resolve-Path` after confirming `git rev-parse` succeeded (exit code 0 / non-empty output); the `if (-not $root)` guard handles the "not a git repo" case before the resolve.

## Open Risks

- GitKraken may not accept `--path` (long form) vs `-p` (short form) — the zsh alias uses `-p`; if GitKraken's argument parser is strict, `--path` might not work. Safest to use `"-p", $root` (matching zsh) rather than `"--path", $root`. Either works in practice but `-p` is confirmed by the existing zsh alias.

## Skills Discovered

| Technology | Skill | Status |
|------------|-------|--------|
| PowerShell | (none applicable) | No skill needed — built-in PS cmdlets cover all requirements |
| Chezmoi templates | (none applicable) | Pattern established by M001/M002 |

## Sources

- Existing zsh alias in `exact_zsh/40-aliases.zsh.tmpl` — direct reference implementation for flag set and UX intent
- Existing `aliases_ps1` fragment — all structural patterns (`function`, `Set-Alias`, section headers) already established
