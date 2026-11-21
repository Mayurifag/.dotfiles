# browser-test

- Follow non-disruptive testing and tool-choice rules in `~/airules/ui-testing.md`.
- Identify the URL and local build/watch process; check dev servers with short timeouts before launch.

## Chrome

- From the target repo, check `browser-test --status`; use `browser-test --launch <url>` if DevTools is unavailable,
  subject to the non-disruptive testing rule.
- Use system Google Chrome only through `browser-test`, never manual profiles/debugging ports. Keep one headed window
  (tabs allowed), not `about:blank`.
- Launch replaces disposable `.opencode/browser-mcp-profile/` from
  `~/.local/share/chezmoi/browser-mcp-template/profile/` and enables loopback permission. Preserve these names; never
  test with the template or normal Chrome profile.
- Store no passwords, personal cookies, or project state in the disposable profile. Missing/broken templates ->
  `~/.local/share/chezmoi/browser-mcp-template/GENERATE.md`.

## Commands

- `browser-test --pages` -> page/extension/service-worker targets; use exact IDs, never guesses.
- `browser-test --target <id> --eval '<expression>'` -> DOM/storage/computed styles/app state; awaits promises, fails on
  JS exceptions.
- `browser-test --target <id> --inspect <seconds> --reload` -> console/errors/failed requests during bounded reload.
  Without `--reload`, only current activity (CDP may replay logs), not past network failures.
- `browser-test --target <id> --navigate <url> --inspect <seconds>` -> navigation activity; navigation alone does not
  wait for load.
- `browser-test --target <id> --screenshot <path>` -> PNG for visual checks.
- Combine actions as needed; inspection/navigation precede eval/screenshot. Navigation/reload/screenshots need page
  targets.
- Prefer `browser-test --tampermonkey-install <url>` and `browser-test --tampermonkey-delete <exact name>` over manager
  pages. If the install result's `reloadedPages` omits the target, reload it before verification.
- `browser-test --help` -> options and env vars.

## Verification

- Verify loaded script/extension version before debugging; script/style status needs only names/versions.
- Test changed behavior; recheck stable setup only on setup failure.
- Prefer console/network/DOM/storage/app-state evidence to sleeps; wait only for an observed async delay.
- Login -> `~/airules/passwords.md`; use repo credentials when available.
- `browser-test` automatically accepts observed JavaScript dialogs, including confirmations; avoid destructive actions
  on live accounts unless explicitly authorized.
- CAPTCHA/unautomatable Chrome permission -> ask the user to resolve in-browser, then confirm before continuing.
- Stale/disconnected CDP -> close and launch one fresh session, not repeated identical failing calls.
- Run `browser-test --close` when finished.
