import { readFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

function read(path, missing) {
  try {
    return readFileSync(path, "utf8").trim();
  } catch (error) {
    return error.code === "ENOENT" ? missing : "unknown";
  }
}

export function readModes(directory, env = process.env) {
  const levels = ["off", "lite", "full", "ultra"];
  let ponytail = read(join(directory, ".ponytail-active"));
  if (ponytail === undefined) {
    const root = env.XDG_CONFIG_HOME || (process.platform === "win32"
      ? env.APPDATA || join(homedir(), "AppData", "Roaming")
      : join(homedir(), ".config"));
    try {
      const config = JSON.parse(read(join(root, "ponytail", "config.json"), "{}"));
      const configured = String(config.defaultMode || "").toLowerCase();
      ponytail = levels.includes(configured) ? configured : "full";
    } catch {
      ponytail = "full";
    }
    const configured = String(env.PONYTAIL_DEFAULT_MODE || "").toLowerCase();
    if (levels.includes(configured)) ponytail = configured;
  }
  const caveman = read(join(directory, ".caveman-active"), "off");
  return {
    caveman: ["lite", "full", "ultra", "wenyan-lite", "wenyan-full", "wenyan-ultra"].includes(caveman)
      ? caveman : caveman === "off" ? "off" : "unknown",
    ponytail: [...levels, "review"].includes(ponytail) ? ponytail : "unknown",
  };
}

// Run with `node modes.mjs --check` to verify flag and default resolution.
if (process.argv[2] === "--check") {
  const { default: assert } = await import("node:assert/strict");
  const { mkdtempSync, mkdirSync, writeFileSync, rmSync } = await import("node:fs");
  const { tmpdir } = await import("node:os");
  const directory = mkdtempSync(join(tmpdir(), "opencode-modes-"));
  const env = { XDG_CONFIG_HOME: directory };
  try {
    assert.deepEqual(readModes(directory, env), { caveman: "off", ponytail: "full" });
    mkdirSync(join(directory, "ponytail"));
    writeFileSync(join(directory, "ponytail", "config.json"), '{"defaultMode":"lite"}');
    assert.equal(readModes(directory, env).ponytail, "lite");
    assert.equal(readModes(directory, { ...env, PONYTAIL_DEFAULT_MODE: "ultra" }).ponytail, "ultra");
    writeFileSync(join(directory, ".ponytail-active"), "off");
    writeFileSync(join(directory, ".caveman-active"), "wenyan-full");
    assert.deepEqual(readModes(directory, env), { caveman: "wenyan-full", ponytail: "off" });
    writeFileSync(join(directory, ".caveman-active"), "invalid");
    assert.equal(readModes(directory, env).caveman, "unknown");
    console.log("Mode status checks passed");
  } finally {
    rmSync(directory, { recursive: true, force: true });
  }
}
