# UserJS and UserCSS

## Versioning

- If both `.js`/`.css` exist, CSS changes also bump the script (it includes the theme).
- Versions belong only in style/script metadata, not `package.json`, lockfiles, or other files; exception: Vite Monkey
  may generate `dist` from `package.json` version.
- No bumps for unrelated changes, e.g. docs only.

## README

- Keep README features current and concise. Public install/update URLs: GitHub
  `/raw/refs/heads/<published-branch>/<path>`, not cached `raw.githubusercontent.com` (delays update detection).
  Determine the branch and path from the project's publishing workflow or source branch; do not assume `dist`.
- README screenshots: web-optimized `.webp` in the repo.

## Browser Testing

- Runtime verification -> `~/airules/browser-testing.md`.
