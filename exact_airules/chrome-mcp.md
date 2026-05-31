# Browser Automation

Use Chrome DevTools MCP for browser/runtime verification.

Trigger this rule for browser UI bugs, frontend runtime behavior, userscripts, Violentmonkey/Tampermonkey, browser extensions, JS configs that affect pages, console/network/storage debugging, screenshots, or DOM verification.

Before launching browser tools:

- Identify the target URL, dev server, userscript, extension, or local build/watch process.
- Check whether the relevant dev process is running before opening Chrome. Examples: Vite/Next/Webpack server, static server, extension build/watch, userscript generator, Violentmonkey-served script.
- Check the expected port or URL with very low timeouts. Fail fast if the port is closed, occupied by the wrong process, or ambiguous.
- Do not guess runtime behavior from source when console, network, DOM, storage, or screenshots can verify it.

Chrome rules:

- Use system-installed Google Chrome through `chrome-devtools-mcp`.
- Set `--user-data-dir` to a dedicated profile directory inside the repository and ensure that directory is gitignored before launching. Never use `~/.cache`, a shared profile, or the user's normal Chrome profile.
- Before launch, ensure no Chrome process is already using the dedicated profile directory. If a stale AI Chrome process or window exists, close it before opening a new one.
- Before launch, ensure the remote-debugging port is free.
- While working, keep exactly one AI Chrome window and one browser session for the dedicated profile/port. Do not open a second window or launch a second browser process for the same task.
- Keep Chrome headed/visible. Do not use headless unless the user asks.
- Avoid stealing focus where the OS allows it. This is best-effort, not guaranteed by Chrome.
- Use very low timeouts and short waits. Prefer 0.5-2s checks, 3s browser-launch timeout, and fast feedback over patience. Increase only after a specific observed reason.

Debugging workflow:

- Open the page, then inspect console errors, failed network requests, DOM state, relevant storage, and screenshots.
- For userscripts/extensions, verify the script or extension version actually loaded in the AI Chrome profile before debugging page behavior.
- If `chrome-devtools MCP error -32000: Connection closed` appears, treat it as a stale/closed browser or MCP session, not an app bug.
- Do not keep retrying the same browser tool call. Close/kill the AI Chrome process for the dedicated profile, verify the remote-debugging port is free, then start one fresh browser session.
- If the MCP server itself stays disconnected, stop and tell the user to restart OpenCode.
- If the browser profile, port, or dev process state is stale, stop and report the exact blocker instead of trying random relaunches.
- When the task is done, close every AI Chrome window opened for the task and confirm the AI Chrome browser process exited. Keep the dedicated profile/context on disk so Chrome can reopen quickly next time.
