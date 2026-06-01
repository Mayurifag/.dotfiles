# Browser Automation

Use Chrome DevTools MCP for browser/runtime verification.

Trigger this rule for browser UI bugs, frontend runtime behavior, userscripts, Tampermonkey, browser extensions, JS configs that affect pages, console/network/storage debugging, screenshots, or DOM verification.

Before launching browser tools:

- Identify the target URL, dev server, userscript, extension, or local build/watch process.
- Check whether the relevant dev process is running before opening Chrome. Examples: Vite/Next/Webpack server, static server, extension build/watch, userscript generator, Tampermonkey-served script.
- Check the expected port or URL with very low timeouts. Fail fast if the port is closed, occupied by the wrong process, or ambiguous.
- Do not guess runtime behavior from source when console, network, DOM, storage, or screenshots can verify it.

Chrome rules:

- OpenCode MCP server name is `browser-mcp`, and it starts `browser-mcp --server` only. Before using browser MCP tools, run `browser-mcp --status`;
  if `devtoolsAvailable` is false, run `browser-mcp --launch <url>` with the target page URL.
- Use system-installed Google Chrome through `browser-mcp` and `chrome-devtools-mcp`; do not launch Chrome manually with a different profile or port.
- Use the repo-local dedicated profile and `browserUrl` reported by `browser-mcp --status`. Never use a shared profile, the template profile directly, or the user's normal Chrome profile.
- If the repo lacks `.opencode/browser-mcp-profile/`, copy `~/.local/share/chezmoi/browser-mcp-template/profile/` there before launching browser-mcp.
- If the template is missing or broken, ask the user to follow `~/.local/share/chezmoi/browser-mcp-template/GENERATE.md`. Do not rely on browser-mcp to use the template automatically.
- If the dedicated profile is broken or missing required extensions, replace it with a fresh copy of `~/.local/share/chezmoi/browser-mcp-template/profile/`.
- Before launch, ensure no Chrome process is already using the dedicated profile directory. If a stale AI Chrome process or window exists, run `browser-mcp --close` before opening a new one.
- Before launch, ensure the remote-debugging port reported by `browser-mcp --status` is free.
- While working, keep exactly one AI Chrome window and one browser session for the dedicated profile/port. Do not open a second window or launch a second browser process for the same task.
- Keep Chrome headed/visible. Do not use headless unless the user asks.
- Do not leave Chrome visibly sitting on `about:blank`; after launch, navigate to the target page immediately.
- Use very low timeouts and short waits. Prefer sub 1s checks, 3s browser-launch timeout, and fast feedback over patience. Increase only after a specific observed reason.

Debugging workflow:

- Open the page, then inspect console errors, failed network requests, DOM state, relevant storage, and screenshots.
- For userscripts/extensions, verify the script or extension version actually loaded in the AI Chrome profile before debugging page behavior.
- If `chrome-devtools MCP error -32000: Connection closed` appears, treat it as a stale/closed browser or MCP session, not an app bug.
- Do not keep retrying the same browser tool call. Close/kill the AI Chrome process for the dedicated profile, verify the remote-debugging port is free, then start one fresh browser session.
- If the MCP server itself stays disconnected, stop and tell the user to restart OpenCode.
- If the browser profile, port, or dev process state is stale, stop and report the exact blocker instead of trying random relaunches.
- Keep Chrome headed/visible. If Chrome shows an unautomatable permission prompt, stop and ask the user to accept it manually, then reload.
- When the task is done, run `browser-mcp --close` and confirm the AI Chrome browser process exited. Keep the dedicated profile/context on disk so Chrome can reopen quickly next time.
