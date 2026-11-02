# UserJS and UserCSS

## Versioning

- If both `.js`/`.css` exist, CSS changes also bump the script (it includes the theme).
- Versions belong only in style/script metadata, not `package.json`, lockfiles, or other files; exception: Vite Monkey
  may generate `dist` from `package.json` version.
- No bumps for unrelated changes, e.g. docs only.

## README

- Keep README features current and concise. Public install/update URLs: GitHub `/raw/refs/heads/dist/`, not cached
  `raw.githubusercontent.com` (delays update detection).
- README screenshots: web-optimized `.webp` in the repo.

## Browser Testing

- Runtime verification -> `~/airules/browser-testing.md`.
