# User.js

Load `~/airules/userjs-usercss.md`.

## Versioning

- Check `git diff` against `HEAD`; for `.js` changes, bump its metadata patch version once per uncommitted diff, never
  again if already changed.

## README

- When adding README installation instructions, keep them concise and link the raw userscript for Tampermonkey.

## Local Development

- Default manager: Tampermonkey unless explicitly overridden. Install local Vite with
  `browser-test --tampermonkey-install http://127.0.0.1:<port>/__vite-plugin-monkey.install.user.js`; dist/published
  scripts only on request.
- Verify GM/Tampermonkey APIs through manager injection, not direct source imports into page context.
- Missing optional UI classes alone do not prove failure; features may be disabled, delayed, or irrelevant.

## Verifying

- Before logic debugging, verify injection once: expected local script in `browser-test --status`, loaded local entry
  request, one real page effect.
- On failure only: Tampermonkey install state, repo profile path, loopback permission, script-list shape, duplicates,
  Vite console status.
- Optional signals (e.g. Vite console status) are diagnostic; do not block when network load and page effect pass.
