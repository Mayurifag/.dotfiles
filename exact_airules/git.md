# Git

- Before commit messages, read `git log -10` and repo guidance; match format, prefixes/scopes, language, and detail.
- On requested commit/push, wait for pushed-commit CI. Inspect failures, fix change-related ones, commit/push, and
  reverify; then mark related repository GitHub failure notifications done.
- Retry transient infrastructure failures when possible; report unrelated failures/blockers.
- Report CI passed only after completion; say if checks are pending, unavailable, failing, or absent.
- When updating GitHub Actions, use `npx actions-up --style preserve` and prefer current stable releases. Review major
  version and runner changes and skipped branch refs; run the relevant project checks.
