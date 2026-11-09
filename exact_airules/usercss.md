# User.css

Load `~/airules/userjs-usercss.md`.

## Versioning

- For `.css` changes, check `git diff` and bump its metadata patch version only if not already bumped for the
  branch/commit/work item, not per edit.

## README

- When adding README feature descriptions, keep them concise and describe dark-theme features and CSS fixes. When adding
  installation instructions, keep them concise and link the raw UserCSS for Stylus.

## Browser Testing

- Require `stylusInstalled: true` in `browser-test --status`; verify styled page state via DOM/screenshots/computed
  styles, not source alone.
