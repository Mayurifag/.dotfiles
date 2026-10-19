import { spawn } from "node:child_process";
import { constants } from "node:fs";
import { access, mkdtemp, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";

const timeout = 120_000;
// Let the privileged supervisor's one-second escalation precede our own.
const grace = 2_000;
const maxOutput = 1024 * 1024;

function run(command, cwd, askpass, supervisor, signal) {
  signal.throwIfAborted();
  return new Promise((resolve, reject) => {
    // With a command, -k ignores and does not update sudoers timestamps.
    const child = spawn(
      "/usr/bin/sudo",
      [
        "-k",
        "-A",
        "-u",
        "root",
        "--",
        supervisor,
        "--signal=TERM",
        "--kill-after=1s",
        "120s",
        "/bin/sh",
        "-c",
        command,
      ],
      {
        cwd,
        detached: true,
        env: { ...process.env, SUDO_ASKPASS: askpass },
        stdio: ["ignore", "pipe", "pipe"],
      },
    );
    const chunks = [];
    let size = 0;
    let truncated = false;
    let stopped;
    let escalation;
    let settled = false;

    const kill = (signal) => {
      if (!child.pid) return;
      try {
        // Include the askpass GUI; sudo forwards TERM to the root timeout,
        // which can escalate within its process group. This is not a tree sandbox.
        process.kill(-child.pid, signal);
      } catch {
        try {
          child.kill(signal);
        } catch {
          // The process may already have exited or become unsignalable.
        }
      }
    };
    const finish = (error, code, exitSignal) => {
      if (settled) return;
      settled = true;
      clearTimeout(deadline);
      clearTimeout(escalation);
      signal.removeEventListener("abort", abort);
      child.stdout.destroy();
      child.stderr.destroy();
      child.unref();
      if (error) return reject(error);
      const output = Buffer.concat(chunks).toString("utf8").trim();
      resolve({
        content: [
          code === null
            ? `Terminated by signal: ${exitSignal}`
            : `Exit code: ${code}`,
          output,
          ...(truncated ? ["[Output truncated at 1 MiB.]"] : []),
        ]
          .filter(Boolean)
          .join("\n"),
      });
    };
    const stop = (reason) => {
      if (stopped || settled) return;
      stopped = reason;
      kill("SIGTERM");
      escalation = setTimeout(() => {
        kill("SIGKILL");
        // Do not wait indefinitely on privileged processes or inherited pipes.
        finish(stopped);
      }, grace);
    };
    const abort = () => stop(new Error("sudo cancelled."));
    const deadline = setTimeout(
      () => stop(new Error("sudo exceeded its 120-second deadline.")),
      timeout,
    );
    for (const stream of [child.stdout, child.stderr]) {
      stream.on("data", (chunk) => {
        const remaining = maxOutput - size;
        if (chunk.length > remaining) truncated = true;
        if (remaining <= 0) return;
        const kept = chunk.subarray(0, remaining);
        chunks.push(kept);
        size += kept.length;
      });
      stream.on("error", () => stop(new Error("Unable to read sudo output.")));
    }
    child.on("error", (error) => {
      if (!stopped) finish(error);
    });
    child.on("close", (code, exitSignal) => {
      if (!stopped) finish(undefined, code, exitSignal);
    });
    signal.addEventListener("abort", abort, { once: true });
    if (signal.aborted) abort();
  });
}

export default {
  id: "local.sudo",
  async setup(ctx) {
    if (!["linux", "darwin"].includes(process.platform)) return;

    const shutdown = new AbortController();
    const active = new Set();

    await ctx.shell.hook("create.before", (event) => {
      if (/^\s*(?:\/usr\/bin\/|\/bin\/)?sudo(?:\s|$)/.test(event.command))
        throw new Error(
          "Use the sudo tool instead of running sudo through shell.",
        );
    });

    await ctx.tool.transform((editor) => {
      editor.add({
        name: "sudo",
        options: { codemode: false },
        description:
          "Run a shell command as root on Linux or macOS, without a leading sudo. " +
          "Uses shell permissions and a graphical kdialog/osascript password prompt for each invocation " +
          "when required by sudo policy. Does not use or refresh cached credentials. " +
          "Has a 120-second deadline, including authentication, plus termination grace; stdin is closed. " +
          "Requires /usr/bin/timeout on Linux or Homebrew gtimeout on macOS. Never provide a password.",
        input: {
          type: "object",
          properties: {
            command: {
              type: "string",
              minLength: 1,
              description:
                "The root shell command, without sudo or a password.",
            },
          },
          required: ["command"],
          additionalProperties: false,
        },
        execute(input, context) {
          const signal = AbortSignal.any([context.signal, shutdown.signal]);
          const execution = (async () => {
            signal.throwIfAborted();
            let cancel;
            const cancelled = new Promise((_, reject) => {
              cancel = () => reject(new Error("sudo cancelled."));
              signal.addEventListener("abort", cancel, { once: true });
            });
            try {
              // Do not catch permission rejection: it must retain its host semantics.
              await Promise.race([
                ctx.permission.assert({
                  sessionID: context.sessionID,
                  agent: context.agent,
                  action: "shell",
                  resources: [input.command],
                  save: [input.command],
                  metadata: { command: input.command, user: "root" },
                  source: {
                    type: "tool",
                    messageID: context.messageID,
                    id: context.id,
                  },
                }),
                cancelled,
              ]);
            } finally {
              signal.removeEventListener("abort", cancel);
            }
            signal.throwIfAborted();

            const supervisors =
              process.platform === "linux"
                ? ["/usr/bin/timeout"]
                : ["/opt/homebrew/bin/gtimeout", "/usr/local/bin/gtimeout"];
            let supervisor;
            for (const candidate of supervisors) {
              try {
                await access(candidate, constants.X_OK);
                supervisor = candidate;
                break;
              } catch {
                // Never fall back to executing an unsupervised root shell.
              }
            }
            if (!supervisor)
              throw new Error(
                `Missing bounded sudo supervisor: executable GNU timeout required at ${supervisors.join(" or ")}.`,
              );
            signal.throwIfAborted();

            const directory = await mkdtemp(join(tmpdir(), "opencode-sudo-"));
            try {
              const askpass = join(directory, "askpass");
              // Only static helper code touches disk. GUI stdout goes directly to
              // sudo's private askpass pipe, never OpenCode or command stdin.
              const prompt =
                process.platform === "darwin"
                  ? `/usr/bin/osascript -e 'text returned of (display dialog "Authentication is required to run a command as root" with title "OpenCode sudo" default answer "" hidden answer true buttons {"Cancel", "OK"} default button "OK" cancel button "Cancel")'`
                  : '/usr/bin/kdialog --title "OpenCode sudo" --password "Authentication is required to run a command as root"';
              await writeFile(
                askpass,
                `#!/bin/sh\nexec ${prompt} 2>/dev/null\n`,
                { mode: 0o700 },
              );
              signal.throwIfAborted();
              return await run(
                input.command,
                ctx.location.directory,
                askpass,
                supervisor,
                signal,
              );
            } finally {
              await rm(directory, { recursive: true, force: true });
            }
          })();
          active.add(execution);
          const done = () => active.delete(execution);
          execution.then(done, done);
          return execution;
        },
      });
    });

    return async () => {
      shutdown.abort();
      await Promise.allSettled([...active]);
    };
  },
};
