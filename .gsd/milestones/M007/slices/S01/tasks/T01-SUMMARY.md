---
id: T01
parent: S01
milestone: M007
provides:
  - GnuWin32.Make added to install/Wingetfile
  - init.ps1 extended from 9 to 14 steps
  - PATH wiring for GnuWin32 bin, Git usr/bin, and mise shims
  - mise config bootstrap (download from GitHub, strip chezmoi directives)
  - Language package installation (npm/cargo/go/gem/uv) via direct commands
  - Post-install instruction block (SSH/ejson/preflight)
key_files:
  - install/Wingetfile
  - windows/init.ps1
key_decisions:
  - "Direct package install commands instead of make — repo isn't cloned during bootstrap, and GnuWin32.Make is unreliable (D024)"
  - "Strip {{ lines from config.toml.tmpl for mise bootstrap — correctly excludes Linux-only conditional-launcher on Windows"
patterns_established:
  - Download raw files from GitHub for pre-chezmoi bootstrap; clean up template directives with simple line filter
  - PATH wiring pattern: refresh from system vars, then prepend tool-specific dirs
duration: 20m
verification_result: pass
completed_at: 2026-03-15
---

# T01: Add GnuWin32.Make to Wingetfile and extend init.ps1

**init.ps1 extended to 14 steps — bootstraps mise config from GitHub, installs runtimes and language packages directly, then prints SSH/ejson/preflight instructions.**

## What Happened

Added `GnuWin32.Make` to Wingetfile in alphabetical position. Extended init.ps1 with 5 new steps (10-14):

Step 10 wires PATH for GnuWin32 bin, Git's usr/bin and mingw64/bin, and mise shims. Step 11 downloads `config.toml.tmpl` from raw GitHub, strips lines containing `{{` (removes chezmoi template directives — this also correctly excludes `conditional-launcher` which is Linux-only), and writes a clean `config.toml` to `~/.config/mise/`. Step 12 runs `mise install --yes`. Step 13 downloads individual install files (npmfile, Rustfile, Gofile, Rubyfile, uv-file) from GitHub and runs each package manager directly — this avoids the make dependency entirely during bootstrap. Step 14 prints the post-install instruction block.

## Deviations

Used direct package install commands instead of `make mise-packages` — the Makefile and packages.mk don't exist on the machine before the repo is cloned. This is cleaner than downloading the entire Makefile infrastructure to a temp dir.

## Files Created/Modified

- `install/Wingetfile` — added `GnuWin32.Make`
- `windows/init.ps1` — extended from 9 to 14 steps with mise bootstrap, package installation, and post-install instructions
