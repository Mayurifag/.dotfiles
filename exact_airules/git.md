# Git

- Before commit messages, read `git log -10` and repo guidance; match format, prefixes/scopes, language, and detail.
- Before pushing, check whether the target branch triggers a production deployment or publishes an artifact. Treat the
  push as that action and ask if the request did not clearly authorize that effect.
- On requested commit/push, wait for pushed-commit CI. Inspect failures, fix change-related ones, commit/push, and
  reverify; then mark related repository GitHub failure notifications done.
- Retry transient infrastructure failures when possible; report unrelated failures/blockers.
- Report CI passed only after completion; say if checks are pending, unavailable, failing, or absent.
- If CI warns that a GitHub Action or its runtime is deprecated, update the affected action and recheck once. When a
  push was requested, commit/push the fix and wait for CI; report warnings without a safe update or that persist.
- When updating GitHub Actions outside the `upgrade-repo` skill, use `npx actions-up --style preserve` and prefer
  current stable releases. Review major-version and runner changes and skipped branch refs; run the relevant project
  checks.
