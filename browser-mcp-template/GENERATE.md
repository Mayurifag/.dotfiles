# Browser Testing Profile

AI-agent runbook for creating `browser-mcp-template/profile/`, a clean local Chrome profile copied into projects as `.opencode/browser-mcp-profile/`.

During execution the script should not change user's system manager windows focus.

`profile/` is gitignored. Do not commit Chrome profile contents.

If user mentioned only this file, it means you are required to run through the following playbook. Do not ask user, go through instructions.

## Generate

Run generation, smoke, install, and delete commands in one dedicated shell from the chezmoi repo root. Set this shell's environment first:

```sh
export OPENCODE_BROWSER_TEST_ALLOW_TEMPLATE_PROFILE=1
export OPENCODE_BROWSER_PROFILE_DIR="$PWD/browser-mcp-template/profile"
```

Keep wrapper/CDP commands in this shell; start the smoke server in a separate shell. The allowance builds the reusable master profile in place.

1. Close Chrome for this profile:
   `browser-test --close`
2. If `browser-mcp-template/profile/` exists, ask before deleting it. If approved:
   `rm -rf browser-mcp-template/profile`
3. Launch from chezmoi repo root. The explicit template-generation allowance builds the profile in place instead of copying an existing template:
   `browser-test --launch https://www.wikipedia.org/`
4. Verify `loopbackNetworkPermissions.default.label` is `allow`:
   `browser-test --status`
5. If missing, close Chrome, set `profile.default_content_setting_values.loopback_network = 1` in `browser-mcp-template/profile/Default/Preferences`, relaunch, recheck.
6. Open Web Store pages with the background-tab helper below for installs.

   Fast CDP helper; it opens the exact URLs from `cdp-tampermonkey.js` in background tabs, then closes non-Web-Store tabs:

   ```sh
   node browser-mcp-template/cdp-tampermonkey.js open-webstore-tabs
   ```

    Verify only those tabs remain with `browser-test --pages`. Nothing else, like Wikipedia.
7. Ask the user to install the opened extensions. They should only click Chrome's install/add-extension prompts.
8. Open `chrome://extensions/?id=dhdgffkkebhmkfjojejmpbldmpobfkfo`; enable `Allow User Scripts`; click `Pin to toolbar`.
9. Open `chrome://extensions/?id=clngdbkpkpeebahjckkjfobafhncgmne`; click `Pin to toolbar`.
10. Open `chrome://extensions/?id=ddkjiahejlhfcafbddmgiahcphecmpfh`; click `Pin to toolbar`.
11. Open `chrome://extensions/?id=oiaejidbmkiecgbjeifoejpgmdaleoha`; click `Pin to toolbar`.
12. Verify install and loopback:
    `browser-test --status`
13. Run the smoke test below.
14. Delete all smoke userscripts from Tampermonkey.
15. Close and final-check:
    `browser-test --close`
    `browser-test --status`

## Smoke Test

The existing fixture keeps its Browser MCP metadata, name, console log, and DOM marker unchanged.

1. Start server from `browser-mcp-template/`:
   `python3 -m http.server 8765 --bind 127.0.0.1`
2. Open `http://127.0.0.1:8765/smoke-test.user.js`.
3. Install with `browser-test --tampermonkey-install http://127.0.0.1:8765/smoke-test.user.js`.
4. Open `https://www.wikipedia.org/`.
5. Find the Wikipedia target ID with `browser-test --pages`. Capture startup events with `browser-test --target <id> --inspect 5 --reload`; verify console log: `browser-mcp wikipedia userscript smoke test`.
6. Verify DOM marker with `browser-test --target <id> --eval 'document.documentElement.dataset.browserMcpWikipediaSmokeTest'`:

   ```js
   document.documentElement.dataset.browserMcpWikipediaSmokeTest
   ```

   Expected: `ok`.
7. Verify the server logged `GET /smoke-test.user.js` from `127.0.0.1`.

## Install Userscript

Install a `.user.js` URL through Tampermonkey:

```sh
browser-test --tampermonkey-install http://127.0.0.1:8765/smoke-test.user.js
```

## Delete Smoke Scripts

First try the wrapper command:

```sh
browser-test --tampermonkey-delete "Browser MCP Smoke Test"
```

If that fails, use Tampermonkey UI:

1. Open `chrome-extension://dhdgffkkebhmkfjojejmpbldmpobfkfo/options.html#nav=dashboard`.
2. Click each smoke script's trash icon.
3. Open `chrome-extension://dhdgffkkebhmkfjojejmpbldmpobfkfo/options.html#nav=trash`.
4. Click `Delete all`; accept every confirmation dialog.
5. Verify the page says `No script is installed`.

Fast CDP delete for visible dashboard/trash controls:

```sh
node browser-mcp-template/cdp-tampermonkey.js delete-smoke
```

If UI says empty but `browser-test --status` still lists smoke scripts, close Chrome and remove only Tampermonkey local script storage:

```sh
browser-test --close
rm -rf "browser-mcp-template/profile/Default/Local Extension Settings/dhdgffkkebhmkfjojejmpbldmpobfkfo"
browser-test --status
```

## Use In Project

Use a fresh shell without the generation environment, or clear it before changing to the target project:

```sh
unset OPENCODE_BROWSER_TEST_ALLOW_TEMPLATE_PROFILE OPENCODE_BROWSER_PROFILE_DIR
```

1. Launch from target project: `browser-test --launch <url>`.
2. Verify `browser-test --status` uses target `.opencode/browser-mcp-profile/`.
3. Install local userscripts with `browser-test --tampermonkey-install <url>`.

## Rules

- Never use the normal Chrome profile.
- Never log into Google.
- Never store passwords or personal cookies.
- Do not debug projects directly with `browser-mcp-template/profile/`; `browser-test --launch` copies it into the project profile.
- Keep exactly one Chrome window for this profile. Tabs are fine.
- Keep Chrome headed/visible.
- Avoid screenshots for routine checks.
- Prefer `browser-test --status`, `browser-test --pages`, `browser-test --target <id> --eval '<expression>'`, `browser-test --target <id> --inspect 5 --reload`, and CDP helpers.
- Use `browser-test --target <id> --screenshot <path>` only when a visible Chrome UI control must be located or a previous direct check failed.
- If Chrome blocks install, permission, pinning, or deletion, ask the user to click it.
