---
estimated_steps: 8
estimated_files: 2
---

# T01: Add GnuWin32.Make to Wingetfile and extend init.ps1

**Slice:** S01 — Complete init.ps1 + preflight.ps1 + INSTRUCTION.md
**Milestone:** M007

## Description

Add GnuWin32.Make to the Wingetfile and extend init.ps1 from its current 9 steps to cover: make install verification + PATH wiring, mise config bootstrap (download from GitHub, strip template directives), mise install, language package installation (npm/cargo/go/gem/uv), and a post-install instruction block covering SSH, ejson, and the preflight.ps1 download command.

## Steps

1. Add `GnuWin32.Make` to `install/Wingetfile` in alphabetical position.
2. In `windows/init.ps1`, after the existing PATH refresh (step 8), add a new step that ensures `C:\Program Files (x86)\GnuWin32\bin` and `C:\Program Files\Git\usr\bin` are on the session PATH. Verify `make --version` is callable; if not, warn and continue (make might not be needed if we fall back to direct commands).
3. Add a step to bootstrap the mise config: download `dot_config/mise/config.toml.tmpl` from raw GitHub, filter out lines containing `{{`, create `$HOME\.config\mise\` if it doesn't exist, write the filtered content to `config.toml`. This gives mise a valid config without chezmoi.
4. Add a step to run `mise install` — this installs all language runtimes (node, go, python, rust, ruby, uv, bun, chezmoi, etc.).
5. Refresh PATH again after mise install (mise installs shims to `~/.local/share/mise/shims/`).
6. Add a step to install language packages. Since the repo isn't cloned yet and make may be flaky, download the install files (npmfile, Rustfile, Gofile, Rubyfile, uv-file) from raw GitHub to a temp dir. Then run each package manager directly: `npm install -g` with npmfile contents, `cargo install` with Rustfile contents, `go install ...@latest` with Gofile contents, `gem install` with Rubyfile contents, `uv tool install` with uv-file contents. This avoids the make dependency entirely for the bootstrap case.
7. Add the post-install instruction block: print SSH setup (KeePassXC SSH Agent → `ssh-add -l`), ejson key symlink (`mklink /D "$HOME\.ejson\keys" "D:\OpenCloud\Personal\Software\dotfiles\ejson\keys"`), and the `preflight.ps1` download command. Emphasize "OPEN A NEW TERMINAL" before running preflight.
8. Renumber all steps to reflect the new total count.

## Must-Haves

- [ ] `GnuWin32.Make` present in `install/Wingetfile`
- [ ] init.ps1 adds GnuWin32 bin and Git usr/bin to session PATH
- [ ] init.ps1 downloads and writes a valid mise config.toml (no chezmoi template directives)
- [ ] init.ps1 runs `mise install`
- [ ] init.ps1 installs language packages (npm, cargo, go, gem, uv) using downloaded install files
- [ ] init.ps1 prints SSH key, ejson key, and preflight.ps1 instructions at the end
- [ ] PS syntax check passes

## Verification

- `Select-String 'GnuWin32.Make' install/Wingetfile` returns a match
- `pwsh -NoProfile -Command "& { [System.Management.Automation.PSParser]::Tokenize((Get-Content 'windows/init.ps1' -Raw), [ref]$null) | Out-Null; 'VALID' }"` returns VALID
- `Select-String 'mise install' windows/init.ps1` returns a match
- `Select-String 'preflight' windows/init.ps1` returns a match
- `Select-String 'KeePassXC' windows/init.ps1` returns a match
- `Select-String 'ejson' windows/init.ps1` returns a match

## Inputs

- `windows/init.ps1` — current 9-step script to extend
- `install/Wingetfile` — current package list
- `dot_config/mise/config.toml.tmpl` — reference for what tools mise needs
- `makefiles/packages.mk` — reference for what package managers to invoke

## Expected Output

- `install/Wingetfile` — with `GnuWin32.Make` added
- `windows/init.ps1` — extended with mise bootstrap, package installation, and post-install instructions
