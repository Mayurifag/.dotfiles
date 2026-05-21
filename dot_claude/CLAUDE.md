# Rules

Do not add comments or descriptions unless explicitly asked.  
Proactively suggest refactoring any file that has grown large. Follow DRY; eliminate tech debt.

## 1. Think Before Coding

**Don’t assume. Surface confusion and tradeoffs.**

Before writing code:

- State assumptions clearly. If uncertain, ask.
- Present multiple interpretations instead of silently choosing one.
- Flag any simpler approach and push back when warranted.
- If anything is unclear, stop and name exactly what’s missing.

## 2. Simplicity First

**Minimum viable code. No speculation.**

- Implement only what was requested.
- Never add abstractions, flexibility, or error handling for unused scenarios.
- If 200 lines can be 50, rewrite it.

Ask: “Would a senior engineer call this over-engineered?” If yes, simplify.

## 3. Surgical Changes

**Change only what you must. Clean only your own mess.**

When editing:

- Never “improve” unrelated code, comments, or formatting.
- Never refactor working code.
- Match existing style exactly.
- If you create unused imports/variables/functions, remove them immediately.
- Remove failed attempt code and any leftovers before trying another approach.
- Never delete pre-existing dead code (mention it if relevant).

Every changed line must trace directly to the user request.

## 4. Goal-Driven Execution

**Define success. Verify before stopping.**

Turn every task into clear, testable criteria:

- “Add validation” → “Tests for invalid inputs pass”
- “Fix bug” → “Reproduction test now passes”

For multi-step work, list a brief plan with verification points. Loop independently until criteria are met.

## Project AGENTS.md

If `AGENTS.md` exists, update it **only** with rare, high-leverage knowledge from user interactions that will be useful across most future tasks.

Focus exclusively on non-obvious, project-specific insights, preferences, constraints, or patterns that an experienced agent would not infer on its own.

- Early-stage projects: capture more foundational information.
- Mature projects: add nothing routine or obvious — only truly valuable, non-trivial details.

## Lockfiles

Never edit lockfiles manually (`Gemfile.lock`, `uv.lock`, `package-lock.json`, `Cargo.lock`, etc.).  
Always use the proper CLI (`bundle install`, `uv add`, `npm install`, `cargo update`, …).

## Markdown Code Blocks

Use `~~~` for code blocks in responses.  
Exception: if the target file already uses ``` (backticks), preserve the same style.

## GitHub

`gh` is installed and authenticated. Use it for any GitHub action instead of web requests.

## Encrypted Secrets (ejson / git-crypt only)

Global git hooks in `~/.config/git/hooks/` automatically handle encryption for repos containing `.ejson` files or `git-crypt` patterns.

- **pre-commit**: auto-encrypts staged `.ejson` plaintext; refuses commit for unencrypted `git-crypt` blobs.
- **pre-push**: blocks push if any commit contains plaintext secrets.

Edit `.ejson` files as normal plaintext — staging triggers encryption.  
For `git-crypt` repos: always use GPG mode with the user’s existing key (never symmetric).  
Clone → `git-crypt unlock`. Check status with `git-crypt status -e`.
