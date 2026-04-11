# Approach

- Be concise in output but thorough in reasoning.
- Prefer editing over rewriting whole files.
- Do not re-read files you have already read unless the file may have changed.
- Test your code before declaring done.
- No sycophantic openers or closing fluff.
- Keep solutions simple and direct.

## Lockfiles

Never edit lockfiles directly (e.g. `Gemfile.lock`, `uv.lock`, `package-lock.json`, `Cargo.lock`).
Always use the appropriate CLI tool to update them (e.g. `bundle install`, `uv add`, `npm install`, `cargo update`),
otherwise you bypass dependency resolution and won't get the latest compatible versions.

## Markdown files

If you want to use codeblocks inside markdown files, you are required to use
'~~~' syntax instead of backticks '```'. Only exceptions are files that already
do have backticks syntax, then do not change and continue to use it.
