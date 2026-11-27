# Developer cleanup

Chezmoi schedules a user job daily at 04:30 local time on macOS, Linux, and Windows. It updates to the latest stable
Node and refreshes the packages in `install/npmfile`. Each run replaces `~/.local/state/dev-cleanup/latest.log`.

- `make dev-cleanup` previews safe Node removals and lists installed Python and Rust versions.
- `make dev-cleanup CLEANUP_ARGS=--apply` updates packages and runs the same cleanup as the job.
- The job keeps Node versions used by tracked configs or visible running processes. It also keeps installs with unlisted
  or linked global npm packages, custom package layouts, or a version that differs from an exact pin in
  `install/npmfile`. For an otherwise unused Node install, listed packages do not block removal if the active npm
  install has them. Bundled npm and Corepack alone do not block removal.
- Mise excludes Node from generic pruning and post-upgrade removal so neither can bypass the global package check. If
  you no longer need packages in an old version, remove them explicitly before the next cleanup. Pin a Node version in
  mise if a project needs it.
- For Python or Rust, check virtual environment interpreter paths, Rustup overrides, project pins, and running processes
  before uninstalling a version. Mise's automatic pruning excludes those tools because it cannot see every reference.
- The job prunes mise and uv caches. Cargo cleans its global download cache using its age limits and cache lock. The job
  keeps project build outputs and virtual environments.
- Run `npm cache verify` separately when npm installs are idle. It can remove temporary files that an install is still
  using.
