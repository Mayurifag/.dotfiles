# Claude Code Rules

Do not add comments and descriptions unless user told you so.
Proactively ask to refactor files that became big. DRY. Eliminate tech debt.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:

- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:

- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:

- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked (suggest to remove if any).

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:

- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:

```text
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

---

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.

## Lockfiles

Never edit lockfiles directly (e.g. `Gemfile.lock`, `uv.lock`, `package-lock.json`, `Cargo.lock`).
Use CLI tool to add/remove/update (e.g. `bundle install`, `uv add`, `npm install`, `cargo update`).

## markdown code

Codeblocks in markdown: use `~~~` not backticks. Exception: file already use backticks — keep as-is.

## GitHub

`gh` installed and authenticated. Use it for any github.com action instead of WebFetch.

## Encrypted secrets (only repos using ejson or git-crypt)

Global git hooks handle secrets — applies when repo has `.ejson` files or `.gitattributes` with `filter=git-crypt`. Hooks live in `~/.config/git/hooks/` (sourced from chezmoi).

- **pre-commit**: auto-encrypts staged plaintext `.ejson` in place via `git update-index` (working tree untouched). For git-crypt files staged plaintext → commit refused; user must `git-crypt unlock`.
- **pre-push**: blocks push if any commit in push range contains plaintext ejson values or unencrypted git-crypt blobs.
- Edit `.ejson` plaintext freely — staging triggers encryption. Don't manually run `ejson encrypt` before `git add`.
- For `git-crypt` repos: assume locked unless told otherwise; if blobs look like binary noise it's encrypted, not corrupt.

### git-crypt: always GPG mode

Key = user's existing GPG key. Never symmetric mode, never separate passphrase.

- Init: `git-crypt init` → `git-crypt add-gpg-user <FPR>` (FPR from `gpg --list-secret-keys --keyid-format=long`).
- Clone: `git-crypt unlock` (uses gpg-agent).
- Lock check: `git-crypt status -e`.
