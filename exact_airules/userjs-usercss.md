# UserJS and UserCSS

## Versioning

- If both `.js` and `.css` exist and `.css` changes, bump `.js` too because the CSS theme is included by the script.
- Keep userstyle/userscript versions only in style/script metadata; do not duplicate versioning in `package.json`, lockfiles, or other project files. Exception: Vite Monkey may use `package.json` version to generate `dist`.
- Do not bump for unrelated changes like documentation-only edits.

## README

- Keep README updated with a concise feature list.
- Use GitHub `/raw/refs/heads/dist/` URLs for public install/update URLs; `raw.githubusercontent.com` caching can delay update detection.
- If README needs a screenshot, save a web-optimized `.webp` screenshot in the repo.

## Browser Testing

- If browser runtime verification is needed, load `~/airules/browser-testing.md`.
