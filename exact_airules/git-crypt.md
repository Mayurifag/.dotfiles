# Encrypted Secrets (ejson / git-crypt only)

Global git hooks in `~/.config/git/hooks/` automatically handle encryption for repos containing `.ejson` files or `git-crypt` patterns.

- **pre-commit**: auto-encrypts staged `.ejson` plaintext; refuses commit for unencrypted `git-crypt` blobs.
- **pre-push**: blocks push if any commit contains plaintext secrets.

Edit `.ejson` files as normal plaintext — staging triggers encryption.
For `git-crypt` repos: always use GPG mode with the user’s existing key (never symmetric).
If the user wants a `git-crypt` file but `git-crypt` is not initialized, run `git-crypt init`, then add the user's verified GPG key with `git-crypt add-gpg-user <key-id>`.
Clone → `git-crypt unlock`. Check status with `git-crypt status -e`.

Try not to print secret values in responses, logs, or diagnostics. Refer only to paths, key names, JSON paths, or validation errors.
My secret files may contain credentials which you are allowed to use. Do not commit or push secrets unencrypted or use unproper ways.
