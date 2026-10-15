import { spawn } from "node:child_process";
import { createInterface } from "node:readline";

export function readCodexUsage(signal) {
  return new Promise((resolve, reject) => {
    const child = spawn("codex", ["app-server", "--listen", "stdio://"], {
      stdio: ["pipe", "pipe", "ignore"],
      signal,
    });
    const lines = createInterface({ input: child.stdout });
    let settled = false;
    const timer = setTimeout(
      () => finish(new Error("Codex usage timed out")),
      15000,
    );
    function finish(error, result) {
      if (settled) return;
      settled = true;
      clearTimeout(timer);
      lines.close();
      child.kill();
      if (error) reject(error);
      else resolve(result);
    }
    const send = (message) => child.stdin.write(`${JSON.stringify(message)}\n`);
    child.on("error", (error) => finish(error));
    child.stdin.on("error", (error) => finish(error));
    child.on("exit", () =>
      finish(new Error("Codex exited before returning usage")),
    );
    lines.on("line", (line) => {
      if (settled) return;
      try {
        const message = JSON.parse(line);
        if (message.id !== 1 && message.id !== 2) return;
        if (message.error)
          throw new Error(message.error.message || "Codex RPC failed");
        if (message.id === 1) {
          send({ method: "initialized", params: {} });
          send({ method: "account/rateLimits/read", id: 2 });
        } else {
          const result = message.result || {};
          const snapshots = Object.values(result.rateLimitsByLimitId || {});
          if (!snapshots.length && result.rateLimits)
            snapshots.push(result.rateLimits);
          finish(undefined, snapshots);
        }
      } catch (error) {
        finish(error);
      }
    });
    send({
      method: "initialize",
      id: 1,
      params: { clientInfo: { name: "opencode_status", version: "1.0.0" } },
    });
  });
}

export function usageRows(snapshots) {
  return snapshots.flatMap((snapshot) =>
    [snapshot.primary, snapshot.secondary].filter(Boolean).map((window) => {
      const minutes = window.windowDurationMins;
      let duration = "unknown window";
      if (Number.isFinite(minutes) && minutes > 0) {
        duration = minutes % 60 === 0 ? `${minutes / 60}h` : `${minutes}m`;
        if (minutes === 10080) duration = "Weekly";
      }
      const left = Number.isFinite(window.usedPercent)
        ? `${Math.max(0, Math.min(100, Math.round(100 - window.usedPercent)))}%`
        : "unknown";
      const reset = window.resetsAt
        ? new Date(window.resetsAt * 1000).toLocaleString()
        : "unknown";
      return `${snapshot.limitName || snapshot.limitId || "Codex"} ${duration}: ${left} left (resets ${reset})`;
    }),
  );
}
