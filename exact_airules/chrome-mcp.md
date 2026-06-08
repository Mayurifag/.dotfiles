# Browser Automation

Use Chrome DevTools MCP for runtime verification.

Before launching browser tools:

- Identify the target URL, dev server, userscript, extension, or local build/watch process.
- Check relevant dev servers with low timeouts before opening Chrome.
- Do not guess runtime behavior from source when console, network, DOM, storage, or screenshots can verify it.

Chrome rules:

- OpenCode MCP server name is `browser-mcp`, and it starts `browser-mcp --server` only.
- Before using browser MCP tools, run `browser-mcp --status`.
- If `devtoolsAvailable` is false, run `browser-mcp --launch <url>` with the target page URL.
- Use system Google Chrome only through `browser-mcp` and `chrome-devtools-mcp`.
- Never launch Chrome manually with another profile or debugging port.
- Use the repo-local `.opencode/browser-mcp-profile/` and `browserUrl` from `browser-mcp --status`.
- Never use the template profile directly or the user's normal Chrome profile.
- `browser-mcp --launch <url>` closes the existing dedicated Chrome, deletes `.opencode/browser-mcp-profile/`, copies `~/.local/share/chezmoi/browser-mcp-template/profile/`, patches loopback permission, then launches Chrome.
- Treat the repo browser profile as disposable. Do not store logins, passwords, personal cookies, or project state there.
- If the template is missing or broken, regenerate it with `~/.local/share/chezmoi/browser-mcp-template/GENERATE.md`.
- Keep exactly one AI Chrome window for the dedicated profile/port. Tabs are fine.
- Keep Chrome headed/visible. Do not use headless unless the user asks.
- Do not leave Chrome on `about:blank`; launch or navigate to the target page.
- Verify the behavior being changed; do not re-check stable setup details unless debugging setup failure.
- Prefer console, network, DOM, storage, or app-state checks over sleeps. Use short waits only for a specific observed async delay.

Tampermonkey commands:

- Install a userscript by URL with `browser-mcp --tampermonkey-install <url>` after Chrome is launched.
- The install command reloads already-open `browser-mcp` tabs matching the userscript `@match`/`@include` metadata.
- Delete a userscript by exact displayed name with `browser-mcp --tampermonkey-delete <name>` after Chrome is launched.
- Prefer these commands over manually opening Tampermonkey extension pages.
- `browser-mcp --status` script/style state only needs names and versions.

Debugging workflow:

- Open the page, then inspect only the console errors, failed network requests, DOM state, storage, or screenshots relevant to the task.
- If a site requires login, look for repo credentials in `git-crypt` files such as `secrets.txt` and use them.
- If a CAPTCHA is visible, stop, prompt the user to solve it in the focused browser window, then continue after the user confirms in chat.
- For userscripts/extensions, verify the script or extension version loaded in the AI Chrome profile before debugging page behavior.
- If `chrome-devtools MCP error -32000: Connection closed` appears, treat it as a stale/closed browser or MCP session, not an app bug.
- Do not retry the same failed browser tool call repeatedly. Run `browser-mcp --close`, then launch one fresh browser session.
- If the MCP server itself stays disconnected, stop and tell the user to restart OpenCode.
- If Chrome shows an unautomatable permission prompt, stop and ask the user to accept it manually, then reload.
- When done, run `browser-mcp --close`.

Cleanup:

- Close extra tabs opened during the task unless the user asked to keep them.
- Reset changed emulation state: viewport, user agent, geolocation, network/CPU throttling, color scheme, and extra headers.
- Stop active performance traces.
- Avoid saving screenshots, traces, Lighthouse reports, heap snapshots, or network dumps unless needed.
- If files were saved, mention their paths and remove temporary ones before finishing.
