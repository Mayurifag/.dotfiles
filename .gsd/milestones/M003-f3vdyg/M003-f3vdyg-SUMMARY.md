---
id: M003-f3vdyg
provides:
  - GitKraken gk function and g alias in .chezmoitemplates/aliases_ps1
key_decisions:
  - Used Get-Item glob with Sort-Object Name -Descending to pick newest versioned install dir
  - Used -p flag (not --path) to match confirmed-working zsh alias
  - Start-Process without -Wait or -NoNewWindow for non-blocking launch
  - Guard clauses with Write-Warning + early return for missing tool and non-git-repo
  - Single slice (no decomposition) — entire milestone was ~10 lines appended to one file
patterns_established:
  - Guard clauses with Write-Warning + early return for missing external tool and non-git-repo
  - Glob-sort pattern (Get-Item app-* | Sort-Object Name -Descending | Select-Object -First 1) for versioned install dirs
observability_surfaces:
  - "grep -A 12 '## GitKraken' .chezmoitemplates/aliases_ps1"
  - "chezmoi execute-template < Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl 2>&1 | grep -A 10 'function gk'"
  - "chezmoi apply --dry-run --force 2>&1 | grep -i error | grep -v 'ejson|decrypt'"
requirement_outcomes: []
duration: ~10m (S01/T01: 5m, S01/T02: <1m)
verification_result: passed
completed_at: 2026-03-15
---

# M003-f3vdyg: GitKraken PS Alias

**Appended a `## GitKraken` section to `.chezmoitemplates/aliases_ps1` with a `gk` function and `Set-Alias -Name g -Value gk`; `chezmoi execute-template` renders both in the deployed PowerShell profile with zero dry-run errors.**

## What Happened

This milestone was a single-slice addition to an already-established file. S01/T01 appended a `## GitKraken` section after the existing `## grep` section at the bottom of `.chezmoitemplates/aliases_ps1`.

The `gk` function:
1. Globs `$env:LOCALAPPDATA\gitkraken\app-*\gitkraken.exe` via `Get-Item … -ErrorAction SilentlyContinue`, sorts by `Name` descending, takes the first result — picks the newest versioned install dir automatically at invocation time.
2. Guards: if no exe found → `Write-Warning "GitKraken not found"` + `return`.
3. Captures git root via `git rev-parse --show-toplevel 2>$null`; guards: if empty → `Write-Warning "Not a git repository"` + `return`.
4. Normalises the POSIX-style path git returns on Windows via `Resolve-Path`.
5. Launches via `Start-Process -FilePath $gkExe -ArgumentList "--new-window", "-p", $root` — non-blocking; prompt returns immediately.

`Set-Alias -Name g -Value gk` follows on the next line, matching zsh muscle memory exactly.

S01/T02 ran `chezmoi execute-template` to confirm both definitions render into the PS profile, and `chezmoi apply --dry-run` to confirm zero new errors. No follow-up fixes were needed.

## Cross-Slice Verification

All success criteria from the roadmap were verified with live commands:

| Success Criterion | Verification Command | Result |
|---|---|---|
| `aliases_ps1` contains `gk` function | `grep -c 'function gk' .chezmoitemplates/aliases_ps1` | 1 ✓ |
| `aliases_ps1` contains `Set-Alias -Name g -Value gk` | `grep -c 'Set-Alias -Name g -Value gk' .chezmoitemplates/aliases_ps1` | 1 ✓ |
| Guard clauses present (not installed) | `grep 'Write-Warning' .chezmoitemplates/aliases_ps1` | "GitKraken not found" + "Not a git repository" ✓ |
| Guard clauses present (not git repo) | same | ✓ |
| `-p` flag used (not `--path`) | `grep 'Start-Process' .chezmoitemplates/aliases_ps1` | `-p` present ✓ |
| `chezmoi execute-template` renders `function gk` | `chezmoi execute-template < Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl \| grep -q 'function gk'` | PASS ✓ |
| `chezmoi execute-template` renders `Set-Alias -Name g -Value gk` | `chezmoi execute-template < … \| grep -q 'Set-Alias -Name g -Value gk'` | PASS ✓ |
| `chezmoi apply --dry-run` produces zero new errors | `chezmoi apply --dry-run --force 2>&1 \| grep -i error \| grep -v 'ejson\|decrypt' \| wc -l` | 0 ✓ |

All criteria from the milestone definition of done are satisfied:
- [x] `aliases_ps1` contains the `## GitKraken` section with `gk` function and `g` alias
- [x] The `gk` function follows established `aliases_ps1` patterns
- [x] `chezmoi execute-template` renders the PS profile with both definitions present
- [x] `chezmoi apply --dry-run` produces no errors related to the change
- [x] Implementation matches zsh alias UX: opens project in new window, backgrounded, returns prompt immediately

## Requirement Changes

No requirements were registered for this milestone — it was new scope beyond M001/M002. No requirement status transitions occurred.

## Forward Intelligence

### What the next milestone should know
- The `gk` function pattern (glob → sort → guard → resolve → `Start-Process`) is a reusable template for other Windows GUI app launchers in `aliases_ps1` (e.g. VS Code, any Electron app with versioned install dirs).
- All PowerShell alias infrastructure is now in place; adding further PS-specific launchers is a straightforward append to `aliases_ps1`.

### What's fragile
- `Sort-Object Name -Descending` relies on GitKraken version directories being lexicographically sortable (e.g. `app-3.10.0`, `app-3.9.0`). Works for semantic version strings but could pick an unexpected entry if GitKraken changes its install dir naming convention.
- Integration testing (actually launching GitKraken) requires Windows + a GitKraken install — cannot be automated on Linux CI. Manual smoke test on Windows is still pending.

### Authoritative diagnostics
- `grep -A 12 '## GitKraken' .chezmoitemplates/aliases_ps1` — fastest way to confirm the section is present and syntactically shaped correctly.
- `chezmoi execute-template < Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl 2>&1 | grep -A 10 'function gk'` — confirms the function renders into the actual deployed profile.

### What assumptions changed
- None — all PS-specific questions (backgrounding, path normalisation, glob pattern) were resolved during research before implementation began; no surprises encountered.

## Files Created/Modified

- `.chezmoitemplates/aliases_ps1` — appended `## GitKraken` section with `gk` function and `Set-Alias -Name g -Value gk`
