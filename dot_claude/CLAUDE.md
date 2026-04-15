Edit over rewrite. Test before done. Simple and direct. Do not add comments and descriptions unless user told you so.
Keep code lines count low, proactively ask to refactor files that became big. DRY. Eliminate tech debt.

## Lockfiles

Never edit lockfiles directly (e.g. `Gemfile.lock`, `uv.lock`, `package-lock.json`, `Cargo.lock`).
Use CLI tool to add/remove/update (e.g. `bundle install`, `uv add`, `npm install`, `cargo update`).

## markdown code

Codeblocks in markdown: use `~~~` not backticks. Exception: file already use backticks — keep as-is.
