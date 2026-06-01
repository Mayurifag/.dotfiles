# User.js / User.css

## Versioning

- If `.js` or `.css` changes, bump the patch version inside them.
- Bump once per branch, commit, or work item, not once per edit. A lot of changes might be in one patch bump, it is fine. If version already changed and not commited, most likely no need to bump further.
- If both files exist and `.css` changes, bump `.js` too because the CSS theme is included by the script.
- Do not bump for unrelated changes in repo. For example, if I changed documentation, that means no features or fixes were added, no meaningful changes.

## README

- Keep README updated with concise list of features user.js provides. For user.css except of darking theme there might be a list of fixed css problems for example.
- README has to have concise section how to install user css (Stylus) with raw link to style and/or user js (Tampermonkey/Violentmonkey).
- Use GitHub `/raw/refs/heads/dist/` URLs for public userscript/UserCSS install and update URLs; `raw.githubusercontent.com` caching can delay update detection.
- User might ask to have README screenshot. It has to be web optimized .webp screenshot saved in some folder in repo.

## Working on user.js

Before debugging with browser MCP, run `browser-mcp --status`. Check if script/style and extensions installed. Setup if needed.

### Setup Tampermonkey and user.js

- Go to installing page and wait user input. User has to install extension and "Allow User Scripts" in extensions settings in Chrome (you cant do that yourself through MCP, wait user).
- After user agreed, proceed installing user.js in Tampermonkey.
- Go to `http://127.0.0.1:<port>/__vite-plugin-monkey.install.user.js`. Tampermonkey redirects to its install flow and opens a hidden/extension page like: `chrome-extension://dhdgffkkebhmkfjojejmpbldmpobfkfo/ask.html?aid=...`
- Browser MCP page tools do not show extension pages. Query DevTools targets directly: `curl -fsS http://127.0.0.1:10143/json/list`
- Find the target whose URL starts with: `chrome-extension://dhdgffkkebhmkfjojejmpbldmpobfkfo/ask.html`
- Connect to its webSocketDebuggerUrl with CDP and click the Install button via JS. Example:

```js
(() => {
  const button = Array.from(document.querySelectorAll('input[type=button],button'))
    .find((el) => (el.value || el.innerText).trim() === 'Install');
  if (!button) return { clicked: false, text: document.body.innerText.slice(0, 500) };
  button.click();
  return { clicked: true };
})()
```

### Verifying

Starting using browser for debug, you have to verify Tampermonkey has already injected the dev userscript by checking page effects, console.log,
console/network for __vite-plugin-monkey.entry.js, and the actual DOM/runtime state.
If its not, install and check that changes persist between launches.
