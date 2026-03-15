# M007: Windows Bootstrap Flow (init → preflight → chezmoi)

**Gathered:** 2026-03-15
**Status:** Queued — pending auto-mode execution

## Project Description

Complete the Windows fresh-install bootstrap pipeline by extending `init.ps1` to install mise packages (via `make mise-packages`) after winget apps, print post-install instructions (SSH key setup via KeePassXC, ejson key symlink), and print the command to download and run the second script. Create `preflight.ps1` — a downloadable readiness-check script that verifies the system has git, bash, chezmoi, ejson (with key), and an SSH key loaded, then offers to run `chezmoi init git@github.com:Mayurifag/.dotfiles.git --ssh`. Update `INSTRUCTION.md` to reflect the new two-script flow and remove stale content.

## Why This Milestone

`init.ps1` currently stops after winget installs and mise profile configuration — step 9/10. There is no automated path from "winget apps installed" to "mise packages installed" to "ready to chezmoi init." The user must manually figure out `make mise-packages`, set up SSH keys, configure ejson, and run chezmoi init. This milestone closes the gap so a fresh Windows install follows a clear `init.ps1` → manual SSH/ejson setup → `preflight.ps1` → chezmoi init pipeline.

## User-Visible Outcome

### When this milestone is complete, the user can:

- Run `init.ps1` on a fresh Windows machine and have winget apps **and** mise packages (node, go, python, rust, ruby, uv, bun, chezmoi, ejson, etc.) fully installed by the end of the script
- See clear printed instructions at the end of `init.ps1` for: (a) setting up SSH key via KeePassXC SSH Agent, (b) symlinking ejson keys from `D:\OpenCloud\Personal\Software\dotfiles\ejson\keys` to `~\.ejson\keys`, (c) the exact command to download and run `preflight.ps1` in a **new terminal**
- Run `preflight.ps1` in a new terminal and have it verify all prerequisites (git, bash, chezmoi, ejson + key, SSH key in agent) before offering to run `chezmoi init`
- Follow `INSTRUCTION.md` which accurately reflects this two-script flow with no stale TODOs or manual steps that the scripts now handle

### Entry point / environment

- Entry point: `Invoke-RestMethod -Uri "https://raw.githubusercontent.com/Mayurifag/.dotfiles/master/windows/init.ps1" | Invoke-Expression` (admin PS), then `Invoke-RestMethod -Uri "https://raw.githubusercontent.com/Mayurifag/.dotfiles/master/windows/preflight.ps1" | Invoke-Expression` (normal PS, new terminal)
- Environment: Windows fresh install, PowerShell 7
- Live dependencies involved: winget, GitHub raw content (script download), mise, npm/cargo/go/gem/uv (package managers installed by mise)

## Completion Class

- Contract complete means: `init.ps1` includes GnuWin32.Make install, `make mise-packages` invocation, and prints SSH/ejson/preflight instructions; `preflight.ps1` exists and performs all readiness checks; `INSTRUCTION.md` reflects the new flow
- Integration complete means: `init.ps1` can be run end-to-end on Windows (winget → mise packages → instructions printed); `preflight.ps1` correctly detects missing prerequisites and blocks chezmoi init when not ready
- Operational complete means: the full pipeline from fresh Windows → chezmoi-managed dotfiles works with only the two manual steps (SSH key + ejson symlink) in between

## Final Integrated Acceptance

To call this milestone complete, we must prove:

- `init.ps1` installs GnuWin32.Make via winget, then runs `make mise-packages` successfully (mise install + node/rust/go/ruby/uv packages)
- `init.ps1` prints clear instructions for SSH key (KeePassXC), ejson key symlink, and the `preflight.ps1` download command at the end
- `preflight.ps1` checks: git available, bash available, chezmoi available, ejson available, ejson key exists at `~\.ejson\keys\`, `ssh-add -l` shows at least one key
- `preflight.ps1` blocks and explains what's missing if any check fails
- `preflight.ps1` offers to run `chezmoi init git@github.com:Mayurifag/.dotfiles.git --ssh` when all checks pass
- `INSTRUCTION.md` accurately describes the `init.ps1` → manual SSH/ejson → `preflight.ps1` flow with no stale steps

## Risks and Unknowns

- **GnuWin32.Make PATH availability** — after winget installs GnuWin32.Make, `make` may not be on PATH until the environment is refreshed. The script already refreshes PATH at step 8/10, but the make install happens after that. Need to refresh PATH again after make install, or reorder. The `make` binary from GnuWin32 installs to `C:\Program Files (x86)\GnuWin32\bin\` — verify the exact winget package ID and install path.
- **make mise-packages on Windows** — the `packages.mk` targets use `cat`, `xargs`, `shell` — these are bash/POSIX utilities. On Windows after Git.Git is installed, Git Bash provides these via `C:\Program Files\Git\usr\bin\`. GnuWin32.Make may or may not find them. May need to ensure Git's usr/bin is on PATH, or run make inside Git Bash rather than PowerShell. This is the biggest unknown.
- **mise install without chezmoi** — `make mise-packages` starts with `mise install`, which reads `~/.config/mise/config.toml`. But on a fresh install before chezmoi, that file doesn't exist yet. The mise global config needs to either be downloaded raw from GitHub or `mise install` needs to be told which tools to install explicitly. This is a sequencing problem: mise config is chezmoi-managed, but chezmoi isn't configured until after preflight.
- **ejson installed via `go install`** — ejson comes from `go install github.com/Shopify/ejson/cmd/ejson@latest` (in Gofile). This happens during `make mise-packages` → `go-packages`. So ejson is only available after init.ps1 completes — the instruction to set up ejson keys is correctly placed at the end.
- **preflight.ps1 does not need admin** — unlike init.ps1, the preflight script should run as a normal user. It should not require elevation.

## Existing Codebase / Prior Art

- `windows/init.ps1` — current script; stops at step 9/10 (mise profile config); needs extension to steps 10+ covering make install, mise packages, and post-install instructions
- `windows/INSTRUCTION.md` — current manual instructions; partially stale; needs update to reflect automated flow
- `install/Wingetfile` — winget package list; `GnuWin32.Make` to be added here
- `install/Gofile` — includes `github.com/Shopify/ejson/cmd/ejson`; installed via `make go-packages`
- `makefiles/packages.mk` — defines `mise-packages` target (mise-install + node/rust/ruby/go/uv packages)
- `dot_config/mise/config.toml.tmpl` — chezmoi-managed mise config; not available on fresh install before chezmoi init
- `Makefile` — top-level; includes `makefiles/*.mk`

> See `.gsd/DECISIONS.md` for all architectural and pattern decisions — it is an append-only register; read it during planning, append to it during execution.

## Relevant Requirements

- None registered — new capability extending the Windows bootstrap pipeline.

## Scope

### In Scope

- Add `GnuWin32.Make` to `install/Wingetfile`
- Extend `init.ps1`:
  - Install GnuWin32.Make (as part of the winget loop, or as a separate early step if ordering matters)
  - After winget installs and PATH refresh: download the mise config from raw GitHub (since chezmoi hasn't run yet), run `mise install`, then `make mise-packages`
  - Print SSH key setup instruction: "Open KeePassXC → Settings → SSH Agent → Enable SSH Agent. Verify with `ssh-add -l`."
  - Print ejson key setup instruction: symlink `~\.ejson\keys` to `D:\OpenCloud\Personal\Software\dotfiles\ejson\keys`
  - Print the exact command to download and run `preflight.ps1` in a **new terminal** (emphasize new terminal for PATH to be correct)
- Create `windows/preflight.ps1`:
  - Check: `git --version` works
  - Check: `bash --version` works (Git Bash)
  - Check: `chezmoi --version` works
  - Check: `ejson` available on PATH
  - Check: ejson key file exists at `~\.ejson\keys\` (directory not empty)
  - Check: `ssh-add -l` shows at least one key (exit code 0, not "The agent has no identities")
  - If any check fails: print what's missing and exit
  - If all pass: ask user confirmation, then run `chezmoi init git@github.com:Mayurifag/.dotfiles.git --ssh`
- Update `windows/INSTRUCTION.md`:
  - Reflect the `init.ps1` → manual SSH/ejson → `preflight.ps1` flow
  - Remove stale TODOs and manual steps that the scripts now handle
  - Keep remaining TODOs that are out of scope for this milestone

### Out of Scope / Non-Goals

- Linux/macOS bootstrap scripts — this is Windows-only
- Automating KeePassXC SSH Agent setup (requires GUI interaction)
- Automating ejson key retrieval from cloud storage (user must symlink manually)
- Any changes to the Makefile or packages.mk targets themselves
- `chezmoi apply` automation — preflight only does `chezmoi init`; the user runs `chezmoi diff` and `chezmoi apply` manually after
- Solving the mise config chicken-and-egg problem permanently — this milestone uses a pragmatic workaround (download raw config from GitHub before chezmoi is set up)

## Technical Constraints

- `init.ps1` requires Administrator (existing constraint); winget + make install need it
- `preflight.ps1` must NOT require Administrator — it runs as normal user
- `make` from GnuWin32 needs POSIX utilities (`cat`, `xargs`, `shell`) — Git for Windows provides these; Git's `usr/bin` must be on PATH when make runs
- `mise install` needs a config file at `~/.config/mise/config.toml` — on fresh install this doesn't exist yet; must bootstrap it (download from raw GitHub or inline the tool list)
- The new terminal requirement between init.ps1 and preflight.ps1 is real — winget installs and PATH changes don't propagate to the running shell reliably
- Step numbering in init.ps1 needs renumbering/extension (currently 1/10 through 9/10)

## Integration Points

- `winget` — installs GnuWin32.Make and all Wingetfile packages
- `mise` — installs language runtimes (node, go, python, rust, ruby, etc.); needs config file before `mise install`
- `make` (GnuWin32) — runs `mise-packages` target which invokes npm/cargo/go/gem/uv installs
- `Git for Windows` — provides bash, POSIX utilities needed by make targets
- `KeePassXC` — user manually enables SSH Agent for SSH key access
- `ejson` — installed by `go install` during mise-packages; user must symlink key directory manually
- `chezmoi` — installed by mise; `preflight.ps1` runs `chezmoi init` when ready

## Open Questions

- **GnuWin32.Make exact winget ID** — need to verify the correct package ID (e.g., `GnuWin32.Make` vs `ezwinports.make` or similar). Check at planning time.
- **make + POSIX utils on Windows** — will `make` from GnuWin32 find `cat`/`xargs` from Git's `usr/bin`? May need to add Git's usr/bin to PATH explicitly before running make, or use a different approach (run make targets individually from PowerShell without make).
- **mise config bootstrap** — best approach for getting mise config onto the machine before chezmoi: (a) download raw `config.toml.tmpl` and strip template directives, (b) download the rendered version somehow, (c) pass tool list directly to `mise install node@lts go@latest ...` without a config file. Option (c) is most robust but duplicates the tool list.
