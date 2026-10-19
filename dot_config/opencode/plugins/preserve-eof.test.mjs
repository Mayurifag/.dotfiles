import assert from "node:assert/strict";
import { mkdtemp, readFile, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import plugin from "./preserve-eof.js";

const directory = await mkdtemp(join(tmpdir(), "opencode-eof-test-"));
try {
  await writeFile(join(directory, ".editorconfig"), "root = true\n[*.txt]\ninsert_final_newline = false\n[*.md]\ninsert_final_newline = true\n");
  const hooks = {};
  const cleanup = await plugin.setup({
    location: { directory, project: { directory } },
    tool: { hook: async (name, callback) => { hooks[name] = callback; } },
  });
  for (const [name, initial, output, expected, status] of [
    ["old.txt", "old", "new\n", "new", "completed"],
    ["windows.txt", "old", "new\r\n", "new", "completed"],
    ["keep.md", "old", "new\n", "new\n", "completed"],
    ["new.txt", undefined, "new\n", "new", "completed"],
    ["failed.txt", "old", "old\n", "old\n", "error"],
  ]) {
    const file = join(directory, name);
    if (initial !== undefined) await writeFile(file, initial);
    const event = {
      tool: "patch", sessionID: "check", id: name,
      input: { patchText: `*** ${initial === undefined ? "Add" : "Update"} File: ${name}` },
    };
    await hooks["execute.before"](event);
    await writeFile(file, output);
    await hooks["execute.after"]({ ...event, status });
    assert.equal(await readFile(file, "utf8"), expected, name);
  }
  cleanup();
  console.log("preserve-eof: update, CRLF, EditorConfig, add, and failed patch checks passed");
} finally {
  await rm(directory, { recursive: true, force: true });
}
