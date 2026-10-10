# Git

- When asked to commit and push, wait for CI checks on pushed commit to finish.
- If checks fail, inspect logs, fix change-related failures, then commit, push, and verify again.
- Retry transient infrastructure failures when possible. Report unrelated failures or blockers.
- Never report CI passed while checks are pending, unavailable, or failing. If no checks run, say so.
