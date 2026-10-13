/** @jsxImportSource @opentui/solid */
import type { TuiPlugin, TuiPluginModule } from "@opencode-ai/plugin/tui";
import { createSignal, For } from "solid-js";
import { readModes } from "./modes.mjs";
import { readCodexUsage, usageRows } from "./codex.mjs";

const tui: TuiPlugin = async (api) => {
  const [modes, setModes] = createSignal(readModes(api.state.path.config));
  const interval = setInterval(
    () => setModes(readModes(api.state.path.config)),
    1000,
  );
  api.lifecycle.onDispose(() => clearInterval(interval));
  const [usage, setUsage] = createSignal(["Loading Codex usage..."]);
  let reading = false;
  const refresh = async () => {
    if (reading || api.lifecycle.signal.aborted) return;
    reading = true;
    try {
      const rows = usageRows(await readCodexUsage(api.lifecycle.signal));
      if (!api.lifecycle.signal.aborted)
        setUsage(rows.length ? rows : ["No Codex usage windows available"]);
    } catch (error) {
      if (!api.lifecycle.signal.aborted)
        setUsage([
          `Codex usage unavailable: ${error instanceof Error ? error.message : String(error)}`,
        ]);
    } finally {
      reading = false;
    }
  };
  void refresh();
  const quotaInterval = setInterval(refresh, 30000);
  api.lifecycle.onDispose(() => clearInterval(quotaInterval));

  const view = () => (
    <box flexDirection="column">
      <text fg={api.theme.current.text}>Caveman: {modes().caveman}</text>
      <text fg={api.theme.current.text}>Ponytail: {modes().ponytail}</text>
      <text fg={api.theme.current.text} marginTop={1}>
        Codex Usage
      </text>
      <For each={usage()}>
        {(row) => <text fg={api.theme.current.textMuted}>{row}</text>}
      </For>
    </box>
  );
  api.slots.register({
    order: 140,
    slots: {
      sidebar_content: view,
      home_bottom: view,
    },
  });
};

export default { id: "mode-status", tui } satisfies TuiPluginModule & {
  id: string;
};
