# User.css

Load `~/airules/userjs-usercss.md`.

## Versioning

- For `.css` changes, check `git diff` and bump its metadata patch version only if not already bumped for the
  branch/commit/work item, not per edit.

## README

- Document dark-theme features/fixed CSS problems; include concise Stylus install instructions and raw UserCSS link.

## Browser Testing

- Require `stylusInstalled: true` in `browser-test --status`; verify styled page state via DOM/screenshots/computed
  styles, not source alone.
