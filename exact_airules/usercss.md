# User.css

Load `~/airules/userjs-usercss.md`.

## Versioning

- If `.css` changes, bump the patch version inside it.
- Before bumping, check `git diff` to see whether the version was already bumped.
- Bump once per branch, commit, or work item, not once per edit.

## README

- For dark themes, include the main theme features and fixed CSS problems.
- Include concise Stylus install instructions with the raw UserCSS link.

## Browser Testing

- Verify `browser-test --status` shows `stylusInstalled: true`.
- Verify the actual styled page state with DOM, screenshots, and computed styles. Do not rely only on source inspection.
