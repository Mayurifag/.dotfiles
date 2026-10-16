/** @jsxImportSource @opentui/solid */
import type { TuiPluginModule } from "@opencode-ai/plugin/tui";
import { createSignal, For } from "solid-js";
import { readCodexUsage, usageRows } from "./codex.mjs";

export default {
  id: "codex-usage",
  async tui(api) {
    const { signal } = api.lifecycle;
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

    const usageTimer = setInterval(refreshUsage, 30000);
    api.lifecycle.onDispose(() => {
      clearInterval(usageTimer);
    });
    void refreshUsage();

    const view = () => (
      <box flexDirection="column" width="100%" maxWidth={75} flexShrink={0}>
        <text fg={api.theme.current.text}>Codex Usage</text>
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
