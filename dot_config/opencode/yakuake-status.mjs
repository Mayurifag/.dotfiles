import { spawnSync } from "node:child_process";
import { closeSync, openSync, writeSync } from "node:fs";
import { basename } from "node:path";

const STATUS = {
  working: "\u{1F7E2}",
  waiting: "\u{1F7E0}",
  ready: "\u{1F535}",
};

export default async ({ directory }) => {
  let terminal;
  try {
    terminal = openSync("/dev/tty", "w");
  } catch {}

  const konsoleService = process.env.KONSOLE_DBUS_SERVICE;
  const konsoleSession = process.env.KONSOLE_DBUS_SESSION;
  if (!terminal && !(konsoleService && konsoleSession)) {
    return {};
  }

  const project = (basename(directory || "") || "OpenCode").replace(
    /[\u0000-\u001f\u007f]/g,
    " ",
  );
  const sessions = new Map();

  const render = () => {
    const sessionStates = [...sessions.values()];
    const status = sessionStates.some((session) => session.pending.size)
      ? "waiting"
      : sessionStates.some((session) => session.busy)
        ? "working"
        : "ready";
    const title = `${STATUS[status]} ${project}`;
    if (konsoleService && konsoleSession) {
      // Konsole role 1 is the displayed tab title, independent of OSC updates.
      const result = spawnSync(
        "qdbus6",
        [konsoleService, konsoleSession, "org.kde.konsole.Session.setTitle", "1", title],
        { stdio: "ignore", timeout: 1000 },
      );
      if (result.status === 0) return;
    }

    if (terminal) {
      try {
        writeSync(
          terminal,
          `\x1b]0;${title}\x07\x1b]1;${title}\x07\x1b]2;${title}\x07`,
        );
      } catch {}
    }
  };

  const sessionState = (sessionID) => {
    let state = sessions.get(sessionID);
    if (!state) {
      state = { busy: false, pending: new Set() };
      sessions.set(sessionID, state);
    }
    return state;
  };

  render();

  return {
    event: async ({ event }) => {
      const properties = event.properties;
      const { sessionID } = properties;
      if (!sessionID) return;

      switch (event.type) {
        case "session.status":
          if (properties.status.type === "idle") {
            const state = sessions.get(sessionID);
            if (state?.pending.size) state.busy = false;
            else sessions.delete(sessionID);
          } else sessionState(sessionID).busy = true;
          break;
        case "session.idle":
          {
            const state = sessions.get(sessionID);
            if (state?.pending.size) state.busy = false;
            else sessions.delete(sessionID);
          }
          break;
        case "session.deleted":
          sessions.delete(sessionID);
          break;
        case "question.asked":
        case "permission.asked": {
          const state = sessionState(sessionID);
          state.busy = true;
          state.pending.add(properties.id);
          break;
        }
        case "question.replied":
        case "question.rejected":
        case "permission.replied": {
          const state = sessions.get(sessionID);
          if (state) state.pending.delete(properties.requestID);
          break;
        }
        default:
          return;
      }

      render();
    },
    dispose: async () => {
      if (terminal) closeSync(terminal);
    },
  };
};
