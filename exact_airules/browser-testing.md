# Browser Testing

- Use `browser-test` only for userscript, userstyle, extension testing, or explicitly requested browser runtime debugging.
- Never use it for general browsing, downloads, or unrelated task verification. No browser MCP is registered.
- Identify the target URL and relevant local build/watch process. Check dev servers with short timeouts before launch.

## Chrome

- Run commands from the target repo. Check `browser-test --status`; launch with `browser-test --launch <url>` if DevTools is unavailable.
- Use system Google Chrome only through `browser-test`. Never launch another profile/debugging port manually.
- Keep one headed Chrome window; tabs are fine. Never leave it on `about:blank`.
- Launch replaces disposable `.opencode/browser-mcp-profile/` from `~/.local/share/chezmoi/browser-mcp-template/profile/` and enables loopback permission.
- These directory names remain unchanged to preserve the existing template. Never use the template or normal Chrome profile for project tests.
- Never store passwords, personal cookies, or project state in the disposable profile.
- If the template is missing/broken, use `~/.local/share/chezmoi/browser-mcp-template/GENERATE.md`.

## Commands

- `browser-test --pages` lists inspectable page/extension/service-worker targets. Select the exact target ID; never guess.
- `browser-test --target <id> --eval '<expression>'` checks DOM, storage, computed styles, or app state. It awaits promises and fails on JavaScript exceptions.
- `browser-test --target <id> --inspect <seconds> --reload` captures console/errors and failed network requests during a bounded reload window.
- Without `--reload`, inspection captures current activity only; it cannot recover past network failures. CDP may replay buffered logs.
- `browser-test --target <id> --navigate <url> --inspect <seconds>` captures navigation activity. Navigation alone does not wait for load.
- `browser-test --target <id> --screenshot <path>` saves PNG when a visual check is needed.
- Target actions can combine; inspection/navigation runs before evaluation and screenshot. Page navigation/reload/screenshots require page targets.
- `browser-test --tampermonkey-install <url>` installs a userscript and reloads open tabs matching `@match`/`@include`.
- `browser-test --tampermonkey-delete <exact name>` deletes a userscript. Prefer these commands over manual manager pages.
- `browser-test --help` documents options and environment variables.

## Verification

- Verify the loaded script/extension version before debugging behavior. Script/style status needs names and versions only.
- Test the changed behavior; do not re-check stable setup unless debugging setup failure.
- Prefer relevant console, network, DOM, storage, or app-state checks over sleeps. Wait only for a specific observed async delay.
- If login is required, load `~/airules/passwords.md` and use repo credentials when available.
- If CAPTCHA or unautomatable Chrome permission appears, ask the user to resolve it in the browser; continue after confirmation.
- On a stale/disconnected CDP session, close and launch one fresh session. Do not repeat the same failed call indefinitely.

## Cleanup

- Run `browser-test --close` when finished.
