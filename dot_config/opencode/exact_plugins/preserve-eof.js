import { parse } from "editorconfig";
import { readFile, writeFile } from "node:fs/promises";
import { isAbsolute, relative, resolve, sep } from "node:path";

const fileHeader = /^\*\*\* (Add|Update) File:\s*(.+?)\s*$/;
const moveHeader = /^\*\*\* Move to:\s*(.+?)\s*$/;

export default {
  id: "local.preserve-eof",
  async setup(ctx) {
    const { directory, project } = ctx.location;
    const pending = new Map();
    const callKey = (event) => `${event.sessionID}:${event.id}`;
    const repoPath = (value) => {
      const file = resolve(directory, value);
      const rel = relative(project.directory, file);
      if (rel === ".." || rel.startsWith(`..${sep}`) || isAbsolute(rel)) return;
      return file;
    };

    await ctx.tool.hook("execute.before", async (event) => {
      if (event.tool !== "patch" || typeof event.input?.patchText !== "string")
        return;
      const key = callKey(event);
      const targets = new Set();
      const lines = event.input.patchText.split(/\r?\n/);
      pending.delete(key);
      for (let index = 0; index < lines.length; index++) {
        const match = lines[index].match(fileHeader);
        if (!match) continue;
        const source = repoPath(match[2]);
        const move =
          match[1] === "Update"
            ? lines[index + 1]?.match(moveHeader)
            : undefined;
        const target = move ? repoPath(move[1]) : source;
        if (!source || !target) continue;
        const setting = (await parse(target)).insert_final_newline;
        if (setting === true) continue;
        if (match[1] === "Add") {
          if (setting === false) targets.add(target);
          continue;
        }
        try {
          const content = await readFile(source);
          if (content.length === 0 || content.at(-1) !== 0x0a)
            targets.add(target);
        } catch (error) {
          if (error.code !== "ENOENT") throw error;
        }
      }
      if (targets.size) pending.set(key, [...targets]);
    });

    await ctx.tool.hook("execute.after", async (event) => {
      if (event.tool !== "patch") return;
      const key = callKey(event);
      const targets = pending.get(key);
      pending.delete(key);
      if (!targets || event.status !== "completed") return;
      for (const file of targets) {
        const content = await readFile(file);
        if (content.at(-1) !== 0x0a) continue;
        const end =
          content.at(-2) === 0x0d ? content.length - 2 : content.length - 1;
        await writeFile(file, content.subarray(0, end));
      }
    });
    return () => pending.clear();
  },
};
