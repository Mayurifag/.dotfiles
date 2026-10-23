# Git

- Before writing a commit message, read recent commits (`git log -10`) and repository commit guidance. Match the
  established format, prefixes/scopes, language, and level of detail; do not impose a different convention.
- When asked to commit and push, wait for CI checks on pushed commit to finish.
- If checks fail, inspect logs, fix change-related failures, then commit, push, and verify again.
- After fixing failed CI, mark this repository's related GitHub failure notifications as done.
- Retry transient infrastructure failures when possible. Report unrelated failures or blockers.
- Never report CI passed while checks are pending, unavailable, or failing. If no checks run, say so.
