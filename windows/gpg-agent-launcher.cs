using System;
using System.Diagnostics;

internal static class GpgAgentLauncher
{
    private static int Main(string[] args)
    {
        if (args.Length != 1)
            return 87;

        try
        {
            // Compile as winexe: neither this launcher nor gpgconf gets a console.
            var startInfo = new ProcessStartInfo(args[0], "--launch gpg-agent")
            {
                UseShellExecute = false,
                CreateNoWindow = true
            };

            using (var process = Process.Start(startInfo))
            {
                if (!process.WaitForExit(20000))
                {
                    process.Kill();
                    return 1460;
                }

                return process.ExitCode;
            }
        }
        catch (Exception)
        {
            // Task Scheduler records a nonzero result and retries without a dialog.
            return 1;
        }
    }
}
