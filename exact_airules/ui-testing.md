# UI Testing and Browser Access

- When changing a dialog, verify that it has an accessible name and that keyboard focus enters on open, stays inside
  while modal, and returns to the trigger on close.

## Non-disruptive Testing

- For browser and desktop UI testing or debugging, prefer headless, non-activating, or isolated sessions when they
  provide valid test coverage.
- Avoid covering the active window, stealing system focus, moving the real pointer, sending system-wide keyboard or
  mouse input, switching desktops, changing the shared clipboard, or producing visible or audible notifications. Do not
  assume a minimized or off-screen window is isolated.
- If a necessary test is likely to interrupt the user, explain the expected impact and ask before proceeding. If
  approval is unavailable or denied, report the verification gap.

## Tool Choice

- Use direct HTTP (`curl`/fetch) or a service-specific CLI when sufficient; follow the research and GitHub rules.
- When a browser is needed for browsing, downloads, other extension tests, or general website/app tests/debugging, use
  `agent-browser` with a named session; close it when finished. No browser MCP is registered.
- Use `browser-test` only for UserJS/UserCSS runtime testing/debugging or maintenance of the tool/template; never for
  general browsing, downloads, other extension or app tests/debugging, or as an `agent-browser` fallback.
- Close task-opened tabs as soon as they are no longer needed, not just at session cleanup; leave pre-existing tabs open
  unless asked otherwise. For `agent-browser`, use `tab close`.

## Task References

- UserJS/UserCSS runtime testing/debugging or browser-test tool/template maintenance ->
  `~/airules/ui-testing/browser-test.md` before using the tool.
- Login -> `~/airules/passwords.md`; use repo credentials when available.
