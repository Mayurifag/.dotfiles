/** @jsxImportSource @opentui/solid */
import type {
  TuiPlugin,
  TuiPluginModule,
  TuiThemeCurrent,
} from "@opencode-ai/plugin/tui";
import {
  createEffect,
  createSignal,
  onCleanup,
  Show,
  Switch,
  Match,
} from "solid-js";

type UsageWindow = {
  usagePercent?: number;
  resetInSec?: number;
};

type Usage = {
  rolling?: UsageWindow | null;
  weekly?: UsageWindow | null;
  monthly?: UsageWindow | null;
};

type State =
  | { status: "loading"; data?: Usage }
  | { status: "ready"; data: Usage }
  | { status: "error"; message: string; data?: Usage };

type Options = {
  refreshMs?: number;
};

const id = "opencode-go-usage-sidebar";
const DEFAULT_REFRESH_MS = 30000;
const MIN_REFRESH_MS = 15000;

function refreshMs(options: Options | undefined) {
  if (
    typeof options?.refreshMs !== "number" ||
    !Number.isFinite(options.refreshMs)
  )
    return DEFAULT_REFRESH_MS;
  return Math.max(MIN_REFRESH_MS, Math.floor(options.refreshMs));
}

function getConfig() {
  const workspaceId = process.env.OPENCODE_GO_WORKSPACE_ID;
  const authCookie = process.env.OPENCODE_GO_AUTH_COOKIE;
  if (!workspaceId || !authCookie)
    throw new Error("Missing OpenCode Go env vars");
  if (!/^wrk_[a-zA-Z0-9]+$/.test(workspaceId))
    throw new Error("Invalid workspace ID format");
  return { workspaceId, authCookie };
}

async function fetchUsage() {
  const { workspaceId, authCookie } = getConfig();
  const response = await fetch(
    `https://opencode.ai/workspace/${encodeURIComponent(workspaceId)}/go`,
    {
      headers: {
        "User-Agent": "Mozilla/5.0",
        Accept:
          "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
        Cookie: `auth=${authCookie}`,
      },
    },
  );

  if (!response.ok) {
    if (response.status === 401 || response.status === 403)
      throw new Error("Authentication failed");
    throw new Error(`HTTP ${response.status}`);
  }

  const html = await response.text();
  const usage: Usage = {};
  const patterns = {
    rolling: /rollingUsage:\$R\[\d+\]=(\{[^}]+\})/,
    weekly: /weeklyUsage:\$R\[\d+\]=(\{[^}]+\})/,
    monthly: /monthlyUsage:\$R\[\d+\]=(\{[^}]+\})/,
  };

  for (const [key, pattern] of Object.entries(patterns)) {
    const match = html.match(pattern);
    if (!match) continue;
    const json = match[1].replace(
      /([{,]\s*)([a-zA-Z_][a-zA-Z0-9_]*)(\s*:)/g,
      '$1"$2"$3',
    );
    usage[key as keyof Usage] = JSON.parse(json);
  }

  if (!usage.rolling && !usage.weekly && !usage.monthly)
    throw new Error("Could not parse usage data");
  return usage;
}

function resetLabel(seconds: number | undefined) {
  if (typeof seconds !== "number") return "unknown";
  if (seconds < 60) return `${seconds}s`;
  if (seconds < 3600) return `${Math.floor(seconds / 60)}m`;
  if (seconds < 86400) {
    const hours = Math.floor(seconds / 3600);
    const mins = Math.floor((seconds % 3600) / 60);
    return mins > 0 ? `${hours}h ${mins}m` : `${hours}h`;
  }
  const days = Math.floor(seconds / 86400);
  const hours = Math.floor((seconds % 86400) / 3600);
  return hours > 0 ? `${days}d ${hours}h` : `${days}d`;
}

function usageColor(percent: number, theme: TuiThemeCurrent) {
  if (percent >= 80) return theme.error;
  if (percent >= 50) return theme.warning;
  return theme.success;
}

function Row(props: {
  label: string;
  item: UsageWindow | null | undefined;
  theme: () => TuiThemeCurrent;
}) {
  return (
    <Show when={props.item}>
      {(item) => {
        const percent = item().usagePercent ?? 0;
        return (
          <box flexDirection="row" gap={0}>
            <text fg={props.theme().textMuted}>{props.label}: </text>
            <text fg={usageColor(percent, props.theme())}>{percent}%</text>
            <text fg={props.theme().textMuted}>
              {" "}
              resets {resetLabel(item().resetInSec)}
            </text>
          </box>
        );
      }}
    </Show>
  );
}

function View(props: {
  options: Options | undefined;
  theme: () => TuiThemeCurrent;
}) {
  const [state, setState] = createSignal<State>({ status: "loading" });
  const [collapsed, setCollapsed] = createSignal(false);
  let disposed = false;
  let running = false;

  const refresh = async () => {
    if (running) return;
    running = true;
    try {
      const data = await fetchUsage();
      if (!disposed) setState({ status: "ready", data });
    } catch (error) {
      if (!disposed)
        setState({
          status: "error",
          message: error instanceof Error ? error.message : String(error),
          data: state().data,
        });
    } finally {
      running = false;
    }
  };

  createEffect(() => {
    void refresh();
  });

  const interval = setInterval(() => void refresh(), refreshMs(props.options));

  onCleanup(() => {
    disposed = true;
    clearInterval(interval);
  });

  return (
    <box flexDirection="column" gap={0}>
      <box
        focusable
        onMouseDown={() => setCollapsed((value) => !value)}
        onKeyDown={(event) => {
          if (event.name === "return" || event.name === "space") {
            event.preventDefault();
            setCollapsed((value) => !value);
          }
        }}
      >
        <text fg={props.theme().text}>
          <b>{collapsed() ? "▶" : "▼"} OpenCode Go Usage</b>
        </text>
      </box>
      <Show when={!collapsed()}>
        <Switch>
          <Match when={state().status === "loading" && !state().data}>
            <text fg={props.theme().textMuted}>
              Loading OpenCode Go usage...
            </text>
          </Match>
          <Match when={state().status === "error" && !state().data}>
            <text fg={props.theme().warning}>{state().message}</text>
          </Match>
          <Match when={state().data}>
            {(data) => (
              <box flexDirection="column" gap={0}>
                <Row
                  label="Rolling"
                  item={data().rolling}
                  theme={props.theme}
                />
                <Row label="Weekly" item={data().weekly} theme={props.theme} />
                <Row
                  label="Monthly"
                  item={data().monthly}
                  theme={props.theme}
                />
                <Show when={state().status === "error"}>
                  <text fg={props.theme().warning}>
                    refresh failed: {(state() as { message?: string }).message}
                  </text>
                </Show>
              </box>
            )}
          </Match>
        </Switch>
      </Show>
    </box>
  );
}

const tui: TuiPlugin = async (api, options) => {
  api.slots.register({
    order: 140,
    slots: {
      sidebar_content() {
        return (
          <View
            options={options as Options | undefined}
            theme={() => api.theme.current}
          />
        );
      },
    },
  });
};

const plugin: TuiPluginModule & { id: string } = { id, tui };

export default plugin;
