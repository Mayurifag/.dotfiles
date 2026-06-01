# User.css

## Versioning

- If `.css` changes, bump the patch version inside it.
- Bump once per branch, commit, or work item, not once per edit.
- If both `.js` and `.css` exist and `.css` changes, bump `.js` too because the CSS theme is included by the script.
- Do not bump for unrelated changes like documentation-only edits.

## README

- Keep README updated with a concise feature list.
- For dark themes, include the main theme features and fixed CSS problems.
- Include concise Stylus install instructions with the raw UserCSS link.
- Use GitHub `/raw/refs/heads/dist/` URLs for public install/update URLs; `raw.githubusercontent.com` caching can delay update detection.
- If README needs a screenshot, save a web-optimized `.webp` screenshot in the repo.

## Browser Testing

- Before debugging with browser MCP, run `browser-mcp --status`.
- Check whether Stylus is installed in the repo-local `.opencode/browser-mcp-profile/`.
- If the profile is missing or Stylus is missing, copy `~/.local/share/chezmoi/browser-mcp-template/profile/` into the repo as `.opencode/browser-mcp-profile/`.
- Verify the actual styled page state with DOM, screenshots, and computed styles. Do not rely only on source inspection.
