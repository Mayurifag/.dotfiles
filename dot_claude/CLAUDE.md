Edit over rewrite. Test before done. Simple and direct.

## Lockfiles

Never edit lockfiles directly (e.g. `Gemfile.lock`, `uv.lock`, `package-lock.json`, `Cargo.lock`).
Use CLI tool to update (e.g. `bundle install`, `uv add`, `npm install`, `cargo update`).
Direct edit bypass dependency resolution, miss latest versions.

## markdown code

Codeblocks in markdown: use `~~~` not backticks. Exception: file already use backticks — keep as-is.
