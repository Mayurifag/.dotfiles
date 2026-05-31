
## Encrypted Secrets (ejson / git-crypt only)

Global git hooks in `~/.config/git/hooks/` automatically handle encryption for repos containing `.ejson` files or `git-crypt` patterns.

- **pre-commit**: auto-encrypts staged `.ejson` plaintext; refuses commit for unencrypted `git-crypt` blobs.
- **pre-push**: blocks push if any commit contains plaintext secrets.

Edit `.ejson` files as normal plaintext — staging triggers encryption.
For `git-crypt` repos: always use GPG mode with the user’s existing key (never symmetric).
Clone → `git-crypt unlock`. Check status with `git-crypt status -e`.
