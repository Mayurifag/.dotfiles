# User.css

## Versioning

- If `.css` changes, bump the patch version inside it.
- Before bumping, check `git diff` to see whether the version was already bumped.
- Bump once per branch, commit, or work item, not once per edit.
- If both `.js` and `.css` exist and `.css` changes, bump `.js` too because the CSS theme is included by the script.
- Keep userstyle/userscript versions only in style/script metadata; do not duplicate versioning in `package.json`, lockfiles, or other project files. Exception: Vite Monkey may use `package.json` version to generate `dist`.
- Do not bump for unrelated changes like documentation-only edits.

## README

- Keep README updated with a concise feature list.
- For dark themes, include the main theme features and fixed CSS problems.
- Include concise Stylus install instructions with the raw UserCSS link.
- Use GitHub `/raw/refs/heads/dist/` URLs for public install/update URLs; `raw.githubusercontent.com` caching can delay update detection.
- If README needs a screenshot, save a web-optimized `.webp` screenshot in the repo.

## Browser Testing

- If browser runtime verification is needed, load `~/airules/chrome-mcp.md`.
- Do not keep manual Stylus edits in `.opencode/browser-mcp-profile/`; browser launches replace it from the template.
- Verify `browser-mcp --status` shows `stylusInstalled: true`.
- Verify style status only by `name` and `version` when status can detect installed styles.
- Verify the actual styled page state with DOM, screenshots, and computed styles. Do not rely only on source inspection.
