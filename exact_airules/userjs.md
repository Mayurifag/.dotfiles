# User.js

## Versioning

- If `.js` changes, bump the patch version inside it.
- Bump once per branch, commit, or work item, not once per edit.
- If both `.js` and `.css` exist and `.css` changes, bump `.js` too because the CSS theme is included by the script.
- Do not bump for unrelated changes like documentation-only edits.

## README

- Keep README updated with a concise feature list.
- Include concise Tampermonkey install instructions with the raw userscript link.
- Use GitHub `/raw/refs/heads/dist/` URLs for public install/update URLs; `raw.githubusercontent.com` caching can delay update detection.
- If README needs a screenshot, save a web-optimized `.webp` screenshot in the repo.

## Local Development

Before debugging with browser MCP, run `browser-mcp --status`.
Check the repo uses `.opencode/browser-mcp-profile/`.
If the profile is missing or Tampermonkey is missing, copy `~/.local/share/chezmoi/browser-mcp-template/profile/` into the repo as `.opencode/browser-mcp-profile/`.

- Install the local Vite userscript URL. Do not install dist/published userscripts unless explicitly requested.
- Before debugging userscript logic, verify the local Vite userscript actually injected by checking network for `__vite-plugin-monkey.entry.js` / `/src/main.js` and one real page effect.
- Do not diagnose GM/Tampermonkey API behavior by importing userscript source directly into page context; verify it through Tampermonkey injection.

## Install Local User.js

- Go to `http://127.0.0.1:<port>/__vite-plugin-monkey.install.user.js`. Tampermonkey redirects to its install flow and opens a hidden/extension page like `chrome-extension://dhdgffkkebhmkfjojejmpbldmpobfkfo/ask.html?aid=...`.
- Browser MCP page tools do not show extension pages. Query DevTools targets directly: `curl -fsS http://127.0.0.1:10143/json/list`.
- Find the target whose URL starts with `chrome-extension://dhdgffkkebhmkfjojejmpbldmpobfkfo/ask.html`.
- Connect to its `webSocketDebuggerUrl` with CDP and click the Install button via JS. Example:

```js
(() => {
  const button = Array.from(document.querySelectorAll('input[type=button],button'))
    .find((el) => (el.value || el.innerText).trim() === 'Install');
  if (!button) return { clicked: false, text: document.body.innerText.slice(0, 500) };
  button.click();
  return { clicked: true };
})()
```

## Verifying

- `browser-mcp --status` shows Tampermonkey installed.
- `browser-mcp --status` shows `loopbackNetworkPermissions.default.label` as `allow`.
- Only the local dev userscript is installed.
- Network shows `http://127.0.0.1:<port>/__vite-plugin-monkey.entry.js` as `200`.
- Network shows `/src/main.js` from local Vite.
- Console shows Vite connected.
- Page effects prove real userscript injection.
