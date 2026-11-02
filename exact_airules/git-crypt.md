# Encrypted Secrets (ejson / git-crypt only)

Global hooks in `~/.config/git/hooks/` handle repos with `.ejson` files or `git-crypt` patterns:

- `pre-commit`: encrypts staged `.ejson` plaintext; rejects unencrypted `git-crypt` blobs.
- `pre-push`: blocks any commit containing plaintext secrets.

- Edit `.ejson` as plaintext; staging triggers encryption.
- `git-crypt`: GPG mode with the user's existing key, never symmetric. If requested but uninitialized, run
  `git-crypt init`, then `git-crypt add-gpg-user <key-id>` with the verified key. After cloning: `git-crypt unlock`;
  inspect with `git-crypt status -e`.
- Credentials may be used for requested tasks; never commit/push plaintext secrets. Refer to paths, key names, JSON
  paths, or validation errors rather than printing secret values in replies/logs/diagnostics.
