using namespace Microsoft.PowerShell

# Match the ConsoleHost profile's Tab behavior across PowerShell sessions.
if ($Host.Name -eq 'ConsoleHost' -and [Environment]::UserInteractive -and -not [Console]::IsInputRedirected) {
    Set-PSReadLineKeyHandler -Chord Tab -BriefDescription SmartTab -ScriptBlock {
        # Script-block handlers can redraw Cyrillic as '?' on non-UTF-8 code pages.
        $encoding = [Console]::OutputEncoding
        try {
            if ($encoding.CodePage -ne 65001) { [Console]::OutputEncoding = [Text.Encoding]::UTF8 }
            $line = $null
            $cursor = 0
            [PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

            if ($line -ceq 'cd ' -and $cursor -eq $line.Length -and
                (Get-Command __zoxide_bin -CommandType Function -ErrorAction SilentlyContinue) -and
                (Get-Command fzf -CommandType Application -ErrorAction SilentlyContinue)) {
                $current = __zoxide_pwd
                $exclude = if ($null -ne $current) { @('--exclude', $current) } else { @() }
                $previousExitCode = $global:LASTEXITCODE
                try {
                    $target = __zoxide_bin query --interactive @exclude
                    if ($LASTEXITCODE -eq 0) {
                        $quoted = "'" + $target.Replace("'", "''") + "'"
                        [PSConsoleReadLine]::Replace(0, $line.Length, "cd $quoted")
                    }
                } finally {
                    [PSConsoleReadLine]::InvokePrompt()
                    $global:LASTEXITCODE = $previousExitCode
                }
                return
            }

            if ($cursor -eq $line.Length) {
                [PSConsoleReadLine]::AcceptSuggestion()
                $updatedLine = $null
                $updatedCursor = 0
                [PSConsoleReadLine]::GetBufferState([ref]$updatedLine, [ref]$updatedCursor)
                if ($updatedLine -cne $line) { return }
            }

            [PSConsoleReadLine]::TabCompleteNext()
        } finally {
            if ($encoding.CodePage -ne 65001) { [Console]::OutputEncoding = $encoding }
        }
    }

    # Complete local paths first, then directories known to zoxide.
    Register-ArgumentCompleter -Native -CommandName cd -ScriptBlock {
        param($wordToComplete, $commandAst, $cursorPosition)

        if ($commandAst.CommandElements.Count -ne 2 -or $cursorPosition -ne $commandAst.Extent.EndOffset) { return }
        $argument = $commandAst.CommandElements[1]
        if ($argument -isnot [System.Management.Automation.Language.StringConstantExpressionAst]) { return }
        if (-not (Get-Command __zoxide_bin -CommandType Function -ErrorAction SilentlyContinue)) { return }

        $query = $argument.Value -replace '^\.[\\/]', '' -replace '[\\/]+$', ''
        if ([string]::IsNullOrWhiteSpace($query)) { return }

        $localLine = "Get-Item $wordToComplete"
        if ((TabExpansion2 -inputScript $localLine -cursorColumn $localLine.Length).CompletionMatches.Count -gt 0) { return }

        $current = __zoxide_pwd
        $exclude = if ($null -ne $current) { @('--exclude', $current) } else { @() }
        $previousExitCode = $global:LASTEXITCODE
        try {
            __zoxide_bin query --list @exclude -- $query 2>$null | ForEach-Object {
                $quoted = "'" + $_.Replace("'", "''") + "'"
                [System.Management.Automation.CompletionResult]::new($quoted, $_, 'ProviderContainer', $_)
            }
        } finally {
            $global:LASTEXITCODE = $previousExitCode
        }
    }
}
