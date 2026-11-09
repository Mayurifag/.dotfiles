import { Plugin } from "@opencode/plugin/tui";
import { TextareaRenderable } from "@opentui/core";

export default Plugin.define({
  id: "q-handoff",
  setup(context) {
    return context.ui.slot({
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
                void launch(directory).catch((error) =>
                  context.ui.toast.show({
                    message: `Could not run q: ${error}`,
                    variant: "error",
                  }),
                );
              },
            },
          ],
        }));
        return null;
      },
    });
  },
});
