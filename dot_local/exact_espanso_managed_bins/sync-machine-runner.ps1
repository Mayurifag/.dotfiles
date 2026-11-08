$python = @(mise.exe which --cd "$HOME" python)
if ($LASTEXITCODE -ne 0 -or $python.Count -ne 1 -or [string]::IsNullOrWhiteSpace($python[0])) {
    [Console]::Error.WriteLine('sync-machine: unable to locate mise-managed Python')
    exit 1
}
if ([IO.Path]::GetExtension($python[0]) -ine '.exe') {
    [Console]::Error.WriteLine('sync-machine: mise must resolve a native Python executable')
    exit 1
}

& $python[0] "$HOME/.agents/skills/sync-machine/scripts/sync_state.py" @args
exit $LASTEXITCODE
