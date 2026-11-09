/** @jsxImportSource @opentui/solid */
import { Plugin } from "@opencode/plugin/tui";
import { TextareaRenderable } from "@opentui/core";
import { Show } from "solid-js";

export default Plugin.define({
  id: "q-handoff",
  setup(context) {
    const [results, updateResults] = context.storage.memory<
      Record<string, string>
    >("results", { initial: {} });
    const notice = (message: string) => (
      <text fg={context.theme.text.base} wrapMode="none" truncate>
        ↳ {message}
      </text>
    );
    const stopNotice = context.ui.slot({
      append: "session.composer.top",
      render: (props) => (
        <Show
          when={
            results[
              `${props.sessionID}:${context.data.session.get(props.sessionID)?.location.directory}`
            ]
          }
        >
          {(message) => notice(message())}
        </Show>
      ),
    });
    const stopPrompt = context.ui.slot({
      append: "prompt.footer",
      render: (props) => {
        const launch = async (directory: string) => {
          await context.renderer.suspend();
          try {
            const command =
              process.platform === "win32"
                ? ["pwsh.exe", "-NoLogo", "-Command", "q"]
                : ["zsh", "-ic", "q"];
            const code = await Bun.spawn(command, {
              cwd: directory,
              stdio: ["inherit", "inherit", "inherit"],
            }).exited;
            if (code !== 0) throw new Error(`exit code ${code}`);
          } finally {
            await context.renderer.resume();
          }

          try {
            const git = Bun.spawn(
              ["git", "--no-pager", "log", "-1", "--format=%s"],
              {
                cwd: directory,
                stderr: "ignore",
              },
            );
            const [output, code] = await Promise.all([
              new Response(git.stdout).text(),
              git.exited,
            ]);
            const subject = output
              .replace(/[\u0000-\u001f\u007f-\u009f]/g, " ")
              .trim();
            if (code === 0 && subject)
              return `q finished · latest commit: ${subject}`;
          } catch {}
          return "q finished";
        };

        context.keymap.layer(() => ({
          priority: 100,
          enabled: props.mode === "normal",
          commands: [
            {
              bind: "return",
              run: () => {
                const prompt = context.renderer.currentFocusedRenderable;
                // OpenCode adds this method to its prompt, not to dialog inputs.
                if (
                  !(prompt instanceof TextareaRenderable) ||
                  typeof (prompt as { getClipboardText?: unknown })
                    .getClipboardText !== "function" ||
                  prompt.plainText !== "q"
                )
                  return false;

                const directory = props.sessionID
                  ? context.data.session.get(props.sessionID)?.location
                      .directory
                  : context.location?.directory;
                if (!directory) {
                  context.ui.toast.show({
                    message: "Could not determine the current directory",
                    variant: "error",
                  });
                  return;
                }
                prompt.setText("");
                const key = props.sessionID
                  ? `${props.sessionID}:${directory}`
                  : directory;
                updateResults((draft) => {
                  delete draft[key];
                });
                void launch(directory)
                  .then((message) =>
                    updateResults((draft) => {
                      draft[key] = message;
                    }),
                  )
                  .catch((error) =>
                    context.ui.toast.show({
                      message: `Could not run q: ${error}`,
                      variant: "error",
                    }),
                  );
              },
            },
          ],
        }));
        return (
          <Show
            when={
              !props.sessionID &&
              context.location &&
              results[context.location.directory]
            }
          >
            {(message) => notice(message())}
          </Show>
        );
      },
    });
    return () => {
      stopNotice();
      stopPrompt();
    };
  },
});
