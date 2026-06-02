# User.js

## Versioning

- Before bumping, check `git diff` against `HEAD`.
- If the userscript version is already changed in the current uncommitted diff, do not bump it again.
- Otherwise, if `.js` changes, bump the patch version inside it exactly once for the current uncommitted diff.
- If both `.js` and `.css` exist and `.css` changes, bump `.js` too because the CSS theme is included by the script.
- Keep userscript versions only in userscript/style metadata; do not duplicate versioning in `package.json`, lockfiles, or other project files. Exception: Vite Monkey may use `package.json` version to generate `dist`.
- Do not bump for unrelated changes like documentation-only edits.

## README

- Keep README updated with a concise feature list.
- Include concise Tampermonkey install instructions with the raw userscript link.
- Use GitHub `/raw/refs/heads/dist/` URLs for public install/update URLs; `raw.githubusercontent.com` caching can delay update detection.
- If README needs a screenshot, save a web-optimized `.webp` screenshot in the repo.

## Local Development

- Before debugging with browser MCP, run `browser-mcp --status`.
- If `devtoolsAvailable` is false, run `browser-mcp --launch <target-url>`.
- `browser-mcp --launch` always replaces `.opencode/browser-mcp-profile/` from the template, so do not keep manual Tampermonkey edits there.
- Tampermonkey is the default userscript manager unless the user explicitly requires another manager.
- Install the local Vite userscript URL with `browser-mcp --tampermonkey-install http://127.0.0.1:<port>/__vite-plugin-monkey.install.user.js`.
- After install, `browser-mcp` reloads already-open tabs matching the userscript `@match`/`@include` metadata.
- Delete a script with `browser-mcp --tampermonkey-delete <exact script name>`.
- Do not install dist/published userscripts unless explicitly requested.
- Before debugging userscript logic, verify local userscript-manager injection once: expected script in `browser-mcp --status`, local entry in network, and one real page effect.
- Do not diagnose GM/Tampermonkey API behavior by importing userscript source directly into page context; verify it through userscript-manager injection.
- Do not conclude the userscript failed only because optional enhanced UI classes are absent; a feature may be disabled, delayed, or irrelevant to the current flow.
- Prefer event, DOM, network, or app-state checks over sleeps. Use short waits only when a specific async delay was observed.
- Verify the changed user-visible behavior; do not checklist unrelated setup details after injection is proven.

## Verifying

- Default checks: expected local script installed, local entry request loaded, and page effect proves injection.
- Failure-only checks: Tampermonkey install state, repo profile path, loopback permission, script list shape, duplicate scripts, Vite console status.
- Optional signals like Vite console status are diagnostic only; do not block on them when network load and page effect pass.
