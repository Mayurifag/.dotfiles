/** @jsxImportSource @opentui/solid */
import type { TuiPluginModule } from "@opencode-ai/plugin/tui";
import { createSignal, For } from "solid-js";
import { readModes } from "./modes.mjs";
import { readCodexUsage, usageRows } from "./codex.mjs";

export default {
  id: "mode-status",
  async tui(api) {
    const { signal } = api.lifecycle;
    const [modes, setModes] = createSignal(readModes(api.state.path.config));
    const [usage, setUsage] = createSignal(["Loading..."]);
    let reading = false;

    const refreshUsage = async () => {
      if (reading || signal.aborted) return;
      reading = true;
      try {
        const rows = usageRows(await readCodexUsage(signal));
        if (!signal.aborted)
          setUsage(rows.length ? rows : ["No usage windows reported"]);
      } catch (error) {
        if (!signal.aborted)
          setUsage([
            `Unavailable: ${error instanceof Error ? error.message : String(error)}`,
          ]);
      } finally {
        reading = false;
      }
    };

    const modeTimer = setInterval(
      () => setModes(readModes(api.state.path.config)),
      1000,
    );
    const usageTimer = setInterval(refreshUsage, 30000);
    api.lifecycle.onDispose(() => {
      clearInterval(modeTimer);
      clearInterval(usageTimer);
    });
    void refreshUsage();

    const view = () => (
      <box flexDirection="column" width="100%" maxWidth={75} flexShrink={0}>
        <text fg={api.theme.current.textMuted}>Reported Modes</text>
        <For each={modes()}>
          {([name, mode]) => (
            <text fg={api.theme.current.text}>
              {name}: {mode}
            </text>
          )}
        </For>
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
      slots: { sidebar_content: view, home_bottom: view },
    });
  },
} satisfies TuiPluginModule & {
  id: string;
};
