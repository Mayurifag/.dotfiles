# Generate Browser MCP Profile

AI-agent runbook for creating `browser-mcp-template/profile/`, a clean local Chrome profile copied into projects as `.opencode/browser-mcp-profile/`.

During execution the script should not change user's system manager windows focus.

`profile/` is gitignored. Do not commit Chrome profile contents.

If user mentioned only this file, it means you are required to run through the following playbook. Do not ask user, go through instructions.

## Generate

1. Close Chrome for this profile:
   `OPENCODE_BROWSER_MCP_ALLOW_TEMPLATE_PROFILE=1 OPENCODE_BROWSER_PROFILE_DIR=browser-mcp-template/profile browser-mcp --close`
2. If `browser-mcp-template/profile/` exists, ask before deleting it. If approved:
   `rm -rf browser-mcp-template/profile`
3. Launch from chezmoi repo root. This copies the existing template into the target profile, so use the template path only while generating the template:
   `OPENCODE_BROWSER_MCP_ALLOW_TEMPLATE_PROFILE=1 OPENCODE_BROWSER_PROFILE_DIR=browser-mcp-template/profile browser-mcp --launch https://www.wikipedia.org/`
4. Verify `loopbackNetworkPermissions.default.label` is `allow`:
   `OPENCODE_BROWSER_MCP_ALLOW_TEMPLATE_PROFILE=1 OPENCODE_BROWSER_PROFILE_DIR=browser-mcp-template/profile browser-mcp --status`
5. If missing, close Chrome, set `profile.default_content_setting_values.loopback_network = 1` in `browser-mcp-template/profile/Default/Preferences`, relaunch, recheck.
6. From the originally launched tab, open Web Store pages. Do not use Browser MCP `new_page` for Web Store installs.

   Fast CDP helper; it opens the exact URLs from `cdp-tampermonkey.js` in background tabs, then closes non-Web-Store tabs:

   ```sh
   node browser-mcp-template/cdp-tampermonkey.js open-webstore-tabs
   ```

   Verify only those tabs remain. Nothing else, like Wikipedia.
7. Ask the user to install the opened extensions. They should only click Chrome's install/add-extension prompts.
8. Open `chrome://extensions/?id=dhdgffkkebhmkfjojejmpbldmpobfkfo`; enable `Allow User Scripts`; click `Pin to toolbar`.
9. Open `chrome://extensions/?id=clngdbkpkpeebahjckkjfobafhncgmne`; click `Pin to toolbar`.
10. Open `chrome://extensions/?id=ddkjiahejlhfcafbddmgiahcphecmpfh`; click `Pin to toolbar`.
11. Open `chrome://extensions/?id=oiaejidbmkiecgbjeifoejpgmdaleoha`; click `Pin to toolbar`.
12. Verify install and loopback:
    `OPENCODE_BROWSER_MCP_ALLOW_TEMPLATE_PROFILE=1 OPENCODE_BROWSER_PROFILE_DIR=browser-mcp-template/profile browser-mcp --status`
13. Run the smoke test below.
14. Delete all smoke userscripts from Tampermonkey.
15. Close and final-check:
    `OPENCODE_BROWSER_MCP_ALLOW_TEMPLATE_PROFILE=1 OPENCODE_BROWSER_PROFILE_DIR=browser-mcp-template/profile browser-mcp --close`
    `OPENCODE_BROWSER_MCP_ALLOW_TEMPLATE_PROFILE=1 OPENCODE_BROWSER_PROFILE_DIR=browser-mcp-template/profile browser-mcp --status`

## Smoke Test

1. Start server from `browser-mcp-template/`:
   `python3 -m http.server 8765 --bind 127.0.0.1`
2. Open `http://127.0.0.1:8765/smoke-test.user.js`.
3. Install with `browser-mcp --tampermonkey-install http://127.0.0.1:8765/smoke-test.user.js`.
4. Open `https://www.wikipedia.org/`.
5. Verify console log: `browser-mcp wikipedia userscript smoke test`.
6. Verify DOM marker:

   ```js
   document.documentElement.dataset.browserMcpWikipediaSmokeTest
   ```

   Expected: `ok`.
7. Verify the server logged `GET /smoke-test.user.js` from `127.0.0.1`.

## Install Userscript

Install a `.user.js` URL through Tampermonkey:

```sh
browser-mcp --tampermonkey-install http://127.0.0.1:8765/smoke-test.user.js
```

## Delete Smoke Scripts

First try the wrapper command:

```sh
browser-mcp --tampermonkey-delete "Browser MCP Smoke Test"
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

If UI says empty but `browser-mcp --status` still lists smoke scripts, close Chrome and remove only Tampermonkey local script storage:

```sh
OPENCODE_BROWSER_MCP_ALLOW_TEMPLATE_PROFILE=1 OPENCODE_BROWSER_PROFILE_DIR=browser-mcp-template/profile browser-mcp --close
rm -rf "browser-mcp-template/profile/Default/Local Extension Settings/dhdgffkkebhmkfjojejmpbldmpobfkfo"
OPENCODE_BROWSER_MCP_ALLOW_TEMPLATE_PROFILE=1 OPENCODE_BROWSER_PROFILE_DIR=browser-mcp-template/profile browser-mcp --status
```

## Use In Project

1. Launch from target project: `browser-mcp --launch <url>`.
2. Verify `browser-mcp --status` uses target `.opencode/browser-mcp-profile/`.
3. Install local userscripts with `browser-mcp --tampermonkey-install <url>`.

## Rules

- Never use the normal Chrome profile.
- Never log into Google.
- Never store passwords or personal cookies.
- Do not debug projects directly with `browser-mcp-template/profile/`; `browser-mcp --launch` copies it into the project profile.
- Keep exactly one Chrome window for this profile. Tabs are fine.
- Keep Chrome headed/visible.
- Avoid `take_snapshot` and screenshots for routine checks.
- Prefer `browser-mcp --status`, `list_pages`, `evaluate_script`, console/network lists, and CDP helpers.
- Use a snapshot only when a visible Chrome UI control must be located or a previous direct check failed.
- If Chrome blocks install, permission, pinning, or deletion, ask the user to click it.
