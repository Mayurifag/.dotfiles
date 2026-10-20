/** @jsxImportSource @opentui/solid */
import { Plugin } from "@opencode/plugin/tui";
import { createSignal, For } from "solid-js";
import { readCodexUsage, usageRows } from "./codex.mjs";

export default Plugin.define({
  id: "codex-usage",
  setup(context) {
    const controller = new AbortController();
    const { signal } = controller;
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

    const view = () => (
      <box flexDirection="column" width="100%" maxWidth={75} flexShrink={0}>
        <text fg={context.theme.text.base}>Codex Usage</text>
        <For each={usage()}>
          {(row) => <text fg={context.theme.text.muted}>{row}</text>}
        </For>
      </box>
    );
    const stopSidebar = context.ui.slot({
      append: "sidebar.content",
      render: view,
    });
    const stopHome = context.ui.slot({ before: "home.footer", render: view });
    const usageTimer = setInterval(refreshUsage, 30000);
    void refreshUsage();

    return () => {
      clearInterval(usageTimer);
      controller.abort();
      stopHome();
      stopSidebar();
    };
  },
});
