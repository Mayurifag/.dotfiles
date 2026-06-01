# User.js / User.css

## Versioning

- If `.js` or `.css` changes, bump the patch version inside them.
- Bump once per branch, commit, or work item, not once per edit. A lot of changes might be in one patch bump, it is fine. If version already changed and not commited, most likely no need to bump further.
- If both files exist and `.css` changes, bump `.js` too because the CSS theme is included by the script.
- Do not bump for unrelated changes in repo. For example, if I changed documentation, that means no features or fixes were added, no meaningful changes.

## README

- Keep README updated with concise list of features user.js provides. For user.css except of darking theme there might be a list of fixed css problems for example.
- README has to have concise section how to install user css (Stylus) with raw link to style and/or user js (Violentmonkey).
- Use GitHub `/raw/refs/heads/dist/` URLs for public userscript/UserCSS install and update URLs; `raw.githubusercontent.com` caching can delay update detection.
- User might ask to have README screenshot. It has to be web optimized .webp screenshot saved in some folder in repo.
