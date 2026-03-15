# M007: Windows Bootstrap Flow (init → preflight → chezmoi)

**Vision:** A fresh Windows install follows a two-script pipeline — `init.ps1` installs all tooling (winget apps + mise packages), prints manual SSH/ejson setup instructions, then `preflight.ps1` verifies readiness and kicks off `chezmoi init`. INSTRUCTION.md reflects this flow accurately.

## Success Criteria

- Running `init.ps1` on a fresh Windows machine installs winget apps, GnuWin32.Make, mise runtimes, and all language packages (npm/cargo/go/gem/uv) without manual intervention
- `init.ps1` prints actionable instructions for SSH key setup (KeePassXC), ejson key symlink, and the `preflight.ps1` download command
- Running `preflight.ps1` in a new terminal verifies git, bash, chezmoi, ejson (with key), and SSH key — then offers `chezmoi init` when all pass
- `INSTRUCTION.md` accurately describes the `init.ps1` → manual setup → `preflight.ps1` flow with no stale steps

## Key Risks / Unknowns

- **GnuWin32.Make silent failure + no PATH** — winget install of GnuWin32.Make can fail silently and never adds `C:\Program Files (x86)\GnuWin32\bin\` to PATH. Script must add it explicitly and verify the binary exists after install.
- **make needs POSIX utils** — `packages.mk` uses `$(shell cat ...)` and `xargs`. On Windows these come from Git for Windows `C:\Program Files\Git\usr\bin\`. Must ensure this is on PATH before running make.
- **mise config chicken-and-egg** — `mise install` reads `~/.config/mise/config.toml` which doesn't exist until chezmoi runs. Must bootstrap a temporary config by downloading the raw template from GitHub and stripping chezmoi directives.

## Proof Strategy

- GnuWin32.Make + POSIX utils → retire in S01 by building the init.ps1 PATH wiring and verifying `make --version` works from PS after install
- mise config bootstrap → retire in S01 by downloading raw config.toml.tmpl, stripping `{{` lines, writing to `~/.config/mise/config.toml`, and running `mise install` successfully

## Verification Classes

- Contract verification: script files exist with correct content; INSTRUCTION.md reflects the two-script flow
- Integration verification: `init.ps1` runs end-to-end on Windows (winget → make → mise packages → instructions printed); `preflight.ps1` detects missing prerequisites correctly
- Operational verification: none (no services or daemons)
- UAT / human verification: run both scripts on a fresh Windows install; verify ejson/SSH manual steps are clear

## Milestone Definition of Done

This milestone is complete only when all are true:

- `init.ps1` extends from 9 steps to cover make install, mise config bootstrap, mise packages, and post-install instructions
- `preflight.ps1` exists and performs all 6 readiness checks (git, bash, chezmoi, ejson, ejson key, SSH key)
- `INSTRUCTION.md` reflects the automated two-script flow and has no stale manual steps that the scripts now handle
- `GnuWin32.Make` is in `install/Wingetfile`
- Script can be tested by running the relevant sections on this Windows machine

## Requirement Coverage

- No REQUIREMENTS.md exists — legacy compatibility mode. This milestone extends the Windows bootstrap pipeline (new capability).
- Orphan risks: none

## Slices

- [x] **S01: Complete init.ps1 + preflight.ps1 + INSTRUCTION.md** `risk:medium` `depends:[]`
  > After this: user runs `init.ps1` on fresh Windows, gets all tooling installed and printed instructions; then runs `preflight.ps1` in a new terminal which verifies readiness and offers `chezmoi init`.

## Boundary Map

### S01 (single slice — no downstream)

Produces:
- `windows/init.ps1` — extended script: GnuWin32.Make install, PATH wiring for make + Git POSIX utils, mise config bootstrap (download raw from GitHub, strip chezmoi directives), `mise install`, `make mise-packages`, post-install instruction block (SSH/ejson/preflight command)
- `windows/preflight.ps1` — new script: 6 readiness checks (git, bash, chezmoi, ejson, ejson key dir, SSH key), user confirmation, `chezmoi init git@github.com:Mayurifag/.dotfiles.git --ssh`
- `windows/INSTRUCTION.md` — updated to reflect two-script flow, stale content removed
- `install/Wingetfile` — `GnuWin32.Make` added

Consumes:
- nothing (first and only slice)
