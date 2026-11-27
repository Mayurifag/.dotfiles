# Temporary workarounds

## Prune specific Node versions

- Location: `dot_local/bin/executable_dev-cleanup`.
- Mise 2026.11.14 and current upstream `prune` filter by tool, not by version, even for `node@VERSION`. Use `mise unuse`
  with exact versions in a temporary config to recheck tracked projects and running processes. The root `--dry-run`
  disables deferred removals during preparation, preview, and scoped pruning. It does not disable explicit `unuse`.
- Replace the temporary config when mise supports exact versions in `prune`. Verify that only the inspected version is
  removed and that a pending removal, a tracked project pin, or a process started after the scan is kept.

## Svelte language server provenance exception

- Location: `dot_config/mise/config.toml.tmpl`, `npm:svelte-language-server`.
- Svelte language server 0.18.6 needs both Svelte 4 and the Svelte 5 Prettier plugin. npm resolves the plugin against
  Svelte 4; mise isolates the dependencies correctly.
- The required `svelte@4.2.20` maintenance release lacks provenance, although the earlier Svelte 5.0.0 release has it.
  Registry signatures and the upstream tag's package metadata were verified; these do not prove source provenance.
- Remove the exact-version exception when the server no longer needs this release or its provenance becomes available.
  Verify installation without the exception and formatting for both Svelte 4 and Svelte 5.

## Cargo cache cleanup on stable

- Location: `dot_local/bin/executable_dev-cleanup`.
- Cargo 1.100 can clean its global cache during `cargo fetch`, but its
  [standalone cleanup](https://github.com/rust-lang/cargo/issues/12633) still requires nightly. A temporary project with
  no dependencies runs the stable cleanup without fetching packages or touching real projects.
- Replace the temporary project when Cargo ships a stable standalone command. Verify that it takes the package cache
  lock.
