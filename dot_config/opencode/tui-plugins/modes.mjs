import { readFileSync } from "node:fs";
import { join } from "node:path";

export function readModes(directory) {
  // These flags are shared plugin state, not proof of hooks running in this session.
  return [
    ["Caveman", ".caveman-active"],
    ["Ponytail", ".ponytail-active"],
  ].map(([name, file]) => {
    try {
      return [
        name,
        readFileSync(join(directory, file), "utf8").trim() || "empty state",
      ];
    } catch (error) {
      return [
        name,
        error.code === "ENOENT"
          ? "not reported"
          : `unavailable (${error.code || "read failed"})`,
      ];
    }
  });
}
