/** @jsxImportSource @opentui/solid */
import { Plugin } from "@opencode/plugin/tui";
import { useTerminalDimensions } from "@opentui/solid";
import { createMemo, Show } from "solid-js";
import { highContextPercent } from "./context.mjs";

export default Plugin.define({
  id: "context-warning",
  setup(context) {
    const percent = (sessionID: string) => {
      const session = context.data.session.get(sessionID);
      return highContextPercent(
        context.data.session.message.list(sessionID),
        context.data.location.model.list(session?.location),
        session?.revert?.messageID,
      );
    };
    const warning = (value: number) => (
      <text
        fg={context.theme.text.feedback.warning.base}
        wrapMode="none"
        flexShrink={0}
      >
        High context: {value}%
      </text>
    );
    const stopSidebar = context.ui.slot({
      prepend: "sidebar.content",
      render: (props) => (
        <Show when={percent(props.sessionID)}>
          {(value) => warning(value())}
        </Show>
      ),
    });
    const stopFooter = context.ui.slot({
      append: "prompt.footer",
      render: (props) => {
        const dimensions = useTerminalDimensions();
        const usage = createMemo(() =>
          props.sessionID ? percent(props.sessionID) : undefined,
        );
        const live = createMemo(() => {
          if (!props.sessionID) return "";
          const subagents = context.data.session
            .family(props.sessionID)
            .filter(
              (id) =>
                id !== props.sessionID &&
                context.data.session.status(id) === "running",
            ).length;
          const shells = context.data.shell
            .list(context.location)
            .filter(
              (shell) => shell.metadata.sessionID === props.sessionID,
            ).length;
          return [
            subagents
              ? `${subagents} subagent${subagents === 1 ? "" : "s"}`
              : "",
            shells ? `${shells} shell${shells === 1 ? "" : "s"}` : "",
          ]
            .filter(Boolean)
            .join(" · ");
        });
        const shortcut = (id: string) => context.keymap.shortcuts(id)[0];
        return (
          <Show
            when={props.mode === "normal"}
            fallback={
              <text fg={context.theme.text.muted}>esc exit shell mode</text>
            }
          >
            <Show when={live()}>
              <text
                fg={context.theme.text.muted}
                wrapMode="none"
                flexShrink={0}
                onMouseUp={() => context.keymap.dispatch("session.child.first")}
              >
                {shortcut("session.child.first")} {live()}
              </text>
            </Show>
            <Show when={usage()}>{(value) => warning(value())}</Show>
            <Show when={props.showDetails && dimensions().width >= 44}>
              <Show when={!usage() && !live()}>
                <text fg={context.theme.text.muted} flexShrink={0}>
                  {shortcut("agent.cycle")} agents
                </text>
              </Show>
              <text
                fg={context.theme.text.muted}
                wrapMode="none"
                flexShrink={0}
              >
                {shortcut("command.palette.show")} commands
              </text>
            </Show>
          </Show>
        );
      },
    });
    return () => {
      stopSidebar();
      stopFooter();
    };
  },
});
