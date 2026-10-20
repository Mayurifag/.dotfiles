import { spawnSync } from "node:child_process";
import { closeSync, openSync, writeSync } from "node:fs";
import { basename } from "node:path";
import { Plugin } from "@opencode/plugin/tui";
import { createEffect, createRoot } from "solid-js";

const STATUS = {
  working: "\u{1F7E2}",
  waiting: "\u{1F7E0}",
  ready: "\u{1F535}",
};

export default Plugin.define({
  id: "yakuake-status",
  setup(context) {
    let terminal;
    try {
      terminal = openSync(
        process.platform === "win32" ? "CONOUT$" : "/dev/tty",
        "w",
      );
    } catch {}

    const konsoleService = process.env.KONSOLE_DBUS_SERVICE;
    const konsoleSession = process.env.KONSOLE_DBUS_SESSION;
    if (terminal === undefined && !(konsoleService && konsoleSession)) {
      return;
    }

    let lastTitle;

    const render = (status, directory) => {
      const project = (basename(directory) || "OpenCode").replace(
        /[\u0000-\u001f\u007f]/g,
        " ",
      );
      const title = `${STATUS[status]} ${project}`;
      if (title === lastTitle) return;
      lastTitle = title;
      if (konsoleService && konsoleSession) {
        // Konsole role 1 is the displayed tab title, independent of OSC updates.
        const result = spawnSync(
          "qdbus6",
          [
            konsoleService,
            konsoleSession,
            "org.kde.konsole.Session.setTitle",
            "1",
            title,
          ],
          { stdio: "ignore", timeout: 1000 },
        );
        if (result.status === 0) return;
      }

      if (terminal !== undefined) {
        try {
          writeSync(
            terminal,
            `\x1b]0;${title}\x07\x1b]1;${title}\x07\x1b]2;${title}\x07`,
          );
        } catch {}
      }
    };

    // Activity can arrive before session metadata has entered the CLI cache.
    const syncSession = (event) => {
      const sessionID =
        event.type === "form.created"
          ? event.data.form.sessionID
          : event.data.sessionID;
      if (sessionID === "global" || context.data.session.get(sessionID)) return;
      const location = context.location ?? context.data.location.default();
      if (
        event.location &&
        (event.location.directory !== location.directory ||
          event.location.workspaceID !== location.workspaceID)
      )
        return;
      void context.data.session.sync(sessionID).catch(() => {});
    };
    const stops = [
      context.data.on("session.execution.started", syncSession),
      context.data.on("permission.asked", syncSession),
      context.data.on("form.created", syncSession),
    ];
    const dispose = createRoot((dispose) => {
      createEffect(() => {
        const location = context.location ?? context.data.location.default();
        const sessions = context.data.session
          .list()
          .filter(
            (session) =>
              session.location.directory === location.directory &&
              session.location.workspaceID === location.workspaceID,
          );
        const waiting =
          context.data.session.form.list("global", location)?.length ||
          sessions.some(
            (session) =>
              context.data.session.permission.list(session.id)?.length ||
              context.data.session.form.list(session.id)?.length,
          );
        const working = sessions.some(
          (session) => context.data.session.status(session.id) === "running",
        );
        render(
          waiting ? "waiting" : working ? "working" : "ready",
          location.directory,
        );
      });
      return dispose;
    });

    return () => {
      stops.forEach((stop) => stop());
      dispose();
      if (terminal !== undefined) closeSync(terminal);
    };
  },
});
