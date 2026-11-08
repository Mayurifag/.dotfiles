<!-- markdownlint-disable MD033 MD041 -->

<bootstrap>
Use this once on another machine after the sync changes have been committed and pushed. The commands preserve the
chezmoi commit and branch before the pull so `aisync` can analyze that entire range. Review Git hooks and filters,
including incoming scripts, before approving the operations below. They are not disabled. If a command fails or asks to
overwrite a locally modified target, stop and resolve it. Do not start another sync during bootstrap.

On macOS/Linux:

```sh
(
  set -e
  source=$(chezmoi source-path)
  before=$(chezmoi git -- rev-parse --verify 'HEAD^{commit}')
  branch=$(chezmoi git -- symbolic-ref --quiet HEAD)
  case "$branch" in refs/heads/*) ;; *) exit 1 ;; esac
  pending="$HOME/.local/state/sync-machine/bootstrap-pending"
  umask 077
  mkdir -p "$(dirname "$pending")"
  (set -C; printf '%s\n%s\n%s\n' "$before" "$branch" "$source" > "$pending")
  name=${branch#refs/heads/}
  remote=$(chezmoi git -- config --get "branch.$name.remote")
  merge=$(chezmoi git -- config --get-all "branch.$name.merge")
  tracking=$(chezmoi git -- rev-parse --symbolic-full-name '@{upstream}')
  case "$remote" in ''|[!a-zA-Z0-9_]*|*[!a-zA-Z0-9_.-]*) exit 1 ;; esac
  case "$merge" in refs/heads/*) ;; *) exit 1 ;; esac
  case "$tracking" in refs/remotes/*) ;; *) exit 1 ;; esac
  chezmoi git -- check-ref-format "$merge"
  chezmoi git -- check-ref-format "$tracking"
  if chezmoi git -- symbolic-ref --quiet "$tracking" >/dev/null 2>&1; then
    exit 1
  else
    [ "$?" -eq 1 ] || exit 1
  fi
  printf 'Review the fetch reference-transaction hook and transport. Fetch now? [y/N] '
  read -r answer
  case "$answer" in y|Y|yes|YES) ;; *) exit 1 ;; esac
  chezmoi git -- fetch --no-prune --no-tags --no-recurse-submodules --no-auto-maintenance \
    --refmap= -- "$remote" "+$merge:$tracking"
  target=$(chezmoi git -- rev-parse --verify "$tracking^{commit}")
  chezmoi git -- diff --no-ext-diff --no-textconv --no-renames --name-only "$before" "$target"
  printf 'Review current and incoming Git hooks and filters. Fast-forward now? [y/N] '
  read -r answer
  case "$answer" in y|Y|yes|YES) ;; *) exit 1 ;; esac
  [ "$(chezmoi git -- symbolic-ref --quiet HEAD)" = "$branch" ]
  [ "$(chezmoi git -- rev-parse --verify 'HEAD^{commit}')" = "$before" ]
  chezmoi git -- merge --ff-only --no-autostash --no-overwrite-ignore "$target"
  changes=$(chezmoi git -- status --porcelain --untracked-files=normal --ignore-submodules=all)
  ignored=$(chezmoi git -- ls-files --others --ignored --exclude-standard --directory)
  printf 'Review local, ignored, and submodule source files before deployment:\n%s\n%s\nContinue with the targeted apply? [y/N] ' "$changes" "$ignored"
  read -r answer
  case "$answer" in y|Y|yes|YES) ;; *) exit 1 ;; esac
  chezmoi apply --parent-dirs \
    "$HOME/.config/opencode/opencode.json" \
    "$HOME/.agents/skills/sync-machine/SKILL.md" \
    "$HOME/.agents/skills/sync-machine/references/bootstrap.md" \
    "$HOME/.agents/skills/sync-machine/scripts/sync_state.py" \
    "$HOME/.local/espanso_managed_bins/sync-machine-runner" \
    "$HOME/zsh/40-aliases.zsh" "$HOME/.bashrc"
  "$HOME/.local/espanso_managed_bins/sync-machine-runner" launch
)
```

On Windows PowerShell 7:

```powershell
& {
$ErrorActionPreference = 'Stop'
$source = chezmoi source-path
if ($LASTEXITCODE -ne 0) { throw 'Unable to read chezmoi source path' }
$before = chezmoi git -- rev-parse --verify 'HEAD^{commit}'
if ($LASTEXITCODE -ne 0) { throw 'Unable to read chezmoi HEAD' }
$branch = chezmoi git -- symbolic-ref --quiet HEAD
if ($LASTEXITCODE -ne 0 -or -not $branch.StartsWith('refs/heads/')) { throw 'Chezmoi HEAD is not a branch' }
$state = Join-Path $HOME '.local/state/sync-machine'
[void][System.IO.Directory]::CreateDirectory($state)
$pending = Join-Path $state 'bootstrap-pending'
$stream = [System.IO.File]::Open($pending, [System.IO.FileMode]::CreateNew, [System.IO.FileAccess]::Write)
try {
  $bytes = [System.Text.Encoding]::UTF8.GetBytes("$before`n$branch`n$source`n")
  $stream.Write($bytes, 0, $bytes.Length)
  $stream.Flush($true)
} finally { $stream.Dispose() }
$name = $branch -replace '^refs/heads/', ''
$remote = chezmoi git -- config --get "branch.$name.remote"
if ($LASTEXITCODE -ne 0 -or $remote -notmatch '^[A-Za-z0-9_][A-Za-z0-9_.-]*$') { throw 'Unsupported remote' }
$merge = @(chezmoi git -- config --get-all "branch.$name.merge")
if ($LASTEXITCODE -ne 0 -or $merge.Count -ne 1 -or -not $merge[0].StartsWith('refs/heads/')) { throw 'Unsupported upstream' }
$tracking = chezmoi git -- rev-parse --symbolic-full-name '@{upstream}'
if ($LASTEXITCODE -ne 0 -or -not $tracking.StartsWith('refs/remotes/')) { throw 'Unsupported tracking ref' }
chezmoi git -- check-ref-format $merge[0]
if ($LASTEXITCODE -ne 0) { throw 'Invalid upstream ref' }
chezmoi git -- check-ref-format $tracking
if ($LASTEXITCODE -ne 0) { throw 'Invalid tracking ref' }
chezmoi git -- symbolic-ref --quiet $tracking
if ($LASTEXITCODE -ne 1) { throw 'Symbolic or invalid tracking ref' }
if ((Read-Host 'Review the fetch reference-transaction hook and transport. Fetch now? [y/N]') -notmatch '^(y|yes)$') { throw 'Fetch not approved' }
chezmoi git -- fetch --no-prune --no-tags --no-recurse-submodules --no-auto-maintenance `
  --refmap= -- $remote "+$($merge[0]):$tracking"
if ($LASTEXITCODE -ne 0) { throw 'Chezmoi fetch failed' }
$target = chezmoi git -- rev-parse --verify "$tracking^{commit}"
if ($LASTEXITCODE -ne 0) { throw 'Unable to read fetched HEAD' }
chezmoi git -- diff --no-ext-diff --no-textconv --no-renames --name-only $before $target
if ($LASTEXITCODE -ne 0) { throw 'Unable to inspect incoming paths' }
if ((Read-Host 'Review current and incoming Git hooks and filters. Fast-forward now? [y/N]') -notmatch '^(y|yes)$') { throw 'Fast-forward not approved' }
if ((chezmoi git -- symbolic-ref --quiet HEAD) -ne $branch -or $LASTEXITCODE -ne 0) { throw 'Branch changed' }
if ((chezmoi git -- rev-parse --verify 'HEAD^{commit}') -ne $before -or $LASTEXITCODE -ne 0) { throw 'HEAD changed' }
chezmoi git -- merge --ff-only --no-autostash --no-overwrite-ignore $target
if ($LASTEXITCODE -ne 0) { throw 'Chezmoi fast-forward failed' }
$changes = @(chezmoi git -- status --porcelain --untracked-files=normal --ignore-submodules=all)
if ($LASTEXITCODE -ne 0) { throw 'Unable to inspect local source changes' }
$ignored = @(chezmoi git -- ls-files --others --ignored --exclude-standard --directory)
if ($LASTEXITCODE -ne 0) { throw 'Unable to inspect ignored source files' }
$changes | ForEach-Object { Write-Host $_ }
$ignored | ForEach-Object { Write-Host $_ }
if ((Read-Host 'Review local, ignored, and submodule source files. Continue with the targeted apply? [y/N]') -notmatch '^(y|yes)$') {
  throw 'Bootstrap apply not approved'
}
chezmoi apply --parent-dirs "$HOME/.config/opencode/opencode.json" `
  "$HOME/.agents/skills/sync-machine/SKILL.md" `
  "$HOME/.agents/skills/sync-machine/references/bootstrap.md" `
  "$HOME/.agents/skills/sync-machine/scripts/sync_state.py" `
  "$HOME/.local/espanso_managed_bins/sync-machine-runner.ps1" `
  "$HOME/Documents/PowerShell/Microsoft.PowerShell_profile.ps1" "$HOME/.bashrc"
if ($LASTEXITCODE -ne 0) { throw 'Chezmoi apply failed' }
& "$HOME/.local/espanso_managed_bins/sync-machine-runner.ps1" launch
if ($LASTEXITCODE -ne 0) { throw 'Sync launcher failed; retain the recovery marker if present' }
}
```

If interrupted, retain `~/.local/state/sync-machine/bootstrap-pending`; do not recreate it or assume an existing runner
is current. Confirm the recorded source and branch, and that its recorded HEAD is an ancestor of the current HEAD. If
needed, repeat the reviewed fetch and fast-forward above, using the current HEAD for the immediate recheck while keeping
the original marker. Review and complete the targeted apply before launching the newly installed runner; it recovers the
original range. Open a new shell afterward to use `aisync`. Do not use `chezmoi update`: its default pull can autostash
and rebase.
</bootstrap>
