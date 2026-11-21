# Setup Scripts

- Sources -> `.chezmoiscripts/{posix,macos,linux,windows}/`; `run_once_`/`run_after_` run during `chezmoi apply`.
- Mark temporary scripts with `one-off:` in a source comment: purpose, affected hosts, verifiable completion condition.
  Do not mark setup still needed on new hosts. For already-run `run_once_` scripts, `one-off` in the filename is an
  alternative if references, ordering, and rendered content stay safe.
- Rendered `run_once_`/`run_onchange_` changes, including comments, can rerun scripts. Use non-rendered template
  comments and verify unchanged rendered bytes when marking existing scripts. Do not edit already-run non-template
  scripts just to add a marker.
- Before removal, follow the live-state and one-off verification rules in `~/airules/chezmoi.md`.
