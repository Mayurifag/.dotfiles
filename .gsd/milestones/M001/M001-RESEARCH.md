# Project Research Summary

**Project:** Cross-shell dotfiles configuration sharing via chezmoi templates
**Domain:** Personal dotfiles — zsh (Linux) / PowerShell (Windows) / Git Bash (Windows) via chezmoi
**Researched:** 2026-03-14
**Confidence:** HIGH

## Executive Summary

This project extends an existing chezmoi-managed dotfiles repo to share aliases, environment variables, and shell tooling (mise, starship, zoxide) across three shells: zsh on Linux, PowerShell 7+ on Windows, and Git Bash on Windows. The expert approach is compile-time generation: chezmoi renders per-shell config files from shared template data at `chezmoi apply` time, so each shell receives a syntactically correct file with no runtime cross-shell parsing. This is architecturally stronger than sourcing a shared shell file at startup because errors surface at apply time, not during interactive sessions.

The recommended approach requires no new dependencies. The full solution is: structured alias/env-var data in `.chezmoidata.toml`, reusable rendering fragments in `.chezmoitemplates/`, OS-conditional file deployment via `.chezmoiignore`, and per-shell target files (`Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl` for Windows, `dot_bashrc.tmpl` for Git Bash). Secrets continue through the existing `ejsonDecrypt` pattern. The existing zsh configuration remains entirely non-destructive — shared alias data is extracted from `40-aliases.zsh` into `.chezmoidata.toml` while the zsh file itself becomes a consumer of that data.

The most significant risks are all template-authoring mistakes: forgetting to pass context (`.`) when including shared templates, generating PowerShell functions with invalid POSIX inline env-var syntax (`LEFTHOOK=0 git push`), and the OneDrive Documents path redirect that can silently prevent the PS profile from deploying. All three risks are preventable at Phase 1 if template conventions are established before content is written. The SSH agent pitfall (Git Bash spawning its own agent instead of reusing the Windows OpenSSH service) is also critical and must be addressed before any SSH-related aliases are added.

---

## Key Findings

### Recommended Stack

chezmoi 2.x provides the entire stack natively — no new tools required. The Go `text/template` engine (with sprig functions), `.chezmoitemplates/` shared fragments, `.chezmoiignore` OS gating, and the existing `ejsonDecrypt` function for secrets are sufficient for all goals. The only external dependencies (ejson binary, mise, starship, zoxide) are already present or managed by the existing Windows setup scripts.

**Core technologies:**
- `chezmoi text/template` engine: per-shell file generation at apply time — zero runtime overhead, errors surface early
- `.chezmoitemplates/`: shared alias/env-var rendering fragments — single source, per-shell output syntax
- `.chezmoiignore` (template-aware): OS-level file gating — PowerShell profile excluded on Linux, Git Bash `.bashrc` excluded on Linux
- `ejsonDecrypt` + `keys.ejson`: secrets at apply time — `GEMINI_API_KEY` never in committed files
- `.chezmoidata.toml`: structured alias registry — TOML data iterated by templates to produce shell-specific syntax

### Expected Features

The core value proposition is alias and environment variable consistency across all three shells without manual duplication. Every other feature depends on the OS-conditional deployment scaffold being correct first.

**Must have (table stakes):**
- OS-conditional deployment scaffold (`.chezmoiignore` + file naming) — everything else depends on this
- Shared env vars rendered per-shell (EDITOR, LC_ALL, GEMINI_API_KEY, PATH additions) — consistency requires this
- mise activation in PowerShell and Git Bash — tools unavailable without it
- Shared alias groups (Navigation, Git) in PowerShell and Git Bash — core value
- SSH agent configuration in Git Bash using Windows OpenSSH service — git operations fail without it
- Non-destructive zsh preservation — existing Linux workflow must not regress

**Should have (competitive):**
- Starship prompt activation on PowerShell — consistent terminal experience, trivially implemented
- zoxide activation on PowerShell — smart navigation on Windows, trivially implemented
- Tool-availability guards for optional tools (eza, lazygit) — graceful degradation
- Git alias group on PowerShell (`gp`, `gpf`, `grc`, `gri`, `lzg`) — high daily-use value

**Defer (v2+):**
- Structured TOML alias data format with range-based template generation — current scale does not justify the indirection cost; explicit template blocks are simpler
- Complex zsh utility function porting (grom, make, f, mkcd) to PowerShell — Linux-workflow functions with no Windows equivalent need
- Docker alias group on Windows — validate Docker Desktop usage first
- Shared shell history — incompatible formats, anti-feature

### Architecture Approach

The architecture is a compile-time template pipeline. `.chezmoidata.toml` holds shared alias and env-var data as structured TOML. `.chezmoitemplates/` contains two families of rendering fragments: POSIX syntax (for zsh and Git Bash) and PowerShell syntax (for `profile.ps1`). Each target shell file includes the relevant fragments and receives the full data context via explicit dot passing (`{{ template "..." . }}`). OS gating happens at the file level via `.chezmoiignore`, not inside file content, keeping individual files clean.

**Major components:**
1. `.chezmoidata.toml` — single source of truth for shared alias groups and env vars; not a template, static TOML only
2. `.chezmoitemplates/aliases_posix` + `aliases_powershell` — shell-specific syntax renderers; iterate over alias data from `.chezmoidata.toml`
3. `.chezmoitemplates/env_vars_posix` + `env_vars_ps1` — env var blocks with `export` vs `$env:` syntax
4. `Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl` — Windows PS7 profile; includes shared fragments + PS-specific activation (mise, starship, zoxide)
5. `dot_bashrc.tmpl` — Git Bash config; includes shared POSIX fragments + Windows OpenSSH agent config
6. `.chezmoiignore` — OS-level gating; excludes `Documents/` subtree on non-Windows

### Critical Pitfalls

1. **Sub-template nil data context** — Always pass trailing dot: `{{ template "shared.tmpl" . }}` not `{{ template "shared.tmpl" }}`. Omitting `.` silently drops `.chezmoi.os` and all variables. Establish this convention in the very first template before writing any content.

2. **POSIX inline env-var syntax in PowerShell** — `LEFTHOOK=0 git push` is invalid PowerShell. All generated PS functions must rewrite these as explicit `$env:LEFTHOOK = "0"; git ...; Remove-Item Env:LEFTHOOK`. This translation rule must be designed into the template before any aliases are written.

3. **PowerShell Set-Alias cannot take arguments** — Virtually every alias from `40-aliases.zsh` includes flags. All must generate as `function name { cmd @args }` blocks, not `Set-Alias` calls. `Set-Alias` is only valid for pure command renames.

4. **SSH agent conflict in Git Bash** — The standard POSIX `eval $(ssh-agent -s)` spawns a second agent conflicting with the Windows OpenSSH service already managed by `init.ps1`. Instead, set `SSH_AUTH_SOCK="//./pipe/openssh-ssh-agent"` and `GIT_SSH` to point at the Windows `ssh.exe`. Never add `eval $(ssh-agent)` to `.bashrc`.

5. **OneDrive Documents path redirect** — On many Windows machines, `Documents` is redirected to `OneDrive\Documents`. The chezmoi source path `Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl` maps to `$HOME/Documents/`, which may not match `$PROFILE`. Verify `$PROFILE` path on each new Windows machine before applying. Do not use `chezmoi add $PROFILE` directly.

---

## Implications for Roadmap

Based on research, the dependency structure mandates this order: template infrastructure first, then Windows shells, then alias content, then validation. All critical pitfalls are Phase 1 concerns — establishing wrong conventions in Phase 1 requires retrofitting all subsequent content.

### Phase 1: Template Infrastructure and Conventions

**Rationale:** Every subsequent file depends on `.chezmoidata.toml`, `.chezmoitemplates/`, and `.chezmoiignore` existing with correct conventions. Building these first means all Phase 2+ content is written once and works immediately. The nil-data-context pitfall, inline env-var translation rules, and `function`-vs-`Set-Alias` decision must all be made here before content is written.
**Delivers:** Working template pipeline skeleton — data file, shared fragment directories, OS gating, translation conventions documented in code comments. `chezmoi execute-template` smoke tests pass.
**Addresses:** OS-conditional deployment scaffold, ejson integration pattern, Linux-only alias exclusion rules
**Avoids:** Sub-template nil data (Pitfall 1), inline env-var syntax errors (Pitfall 4), Set-Alias with arguments (Pitfall 6)

### Phase 2: PowerShell Profile

**Rationale:** PowerShell profile has the most OS-specific complexity (path mapping, encoding, CRLF, `function` blocks) and is the highest-value Windows deliverable. Building it before Git Bash ensures the shared template fragments are proven correct with the harder case first.
**Delivers:** Fully functional `Microsoft.PowerShell_profile.ps1` — mise activation, starship, zoxide, shared env vars, Navigation and Git alias groups as PS functions, CRLF/encoding directives
**Uses:** `.chezmoitemplates/aliases_powershell`, `.chezmoitemplates/env_vars_ps1`, `ejsonDecrypt` pattern
**Implements:** `Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl` + `.chezmoiignore` Windows gating
**Avoids:** OneDrive path pitfall (Pitfall 2), CRLF endings (Pitfall 7), UTF-8 BOM assumption (Pitfall 8), ejson on Windows (verify EJSON_KEYDIR)

### Phase 3: Git Bash Configuration

**Rationale:** Git Bash `.bashrc` reuses the POSIX template fragments already proven in Phase 2. The primary new concern is the SSH agent configuration — this must use the Windows OpenSSH service, not spawn a new agent.
**Delivers:** Functional `~/.bashrc` for Git Bash — mise activation, Windows OpenSSH agent config (`SSH_AUTH_SOCK` + `GIT_SSH`), shared POSIX env vars, Navigation and Git alias groups
**Uses:** `.chezmoitemplates/aliases_posix`, `.chezmoitemplates/env_vars_posix`, `dot_bashrc.tmpl` converted to template
**Avoids:** SSH agent conflict (Pitfall 3), Linux-only aliases in Windows shells (UX pitfall)

### Phase 4: Shared Alias Data Extraction and Zsh Alignment

**Rationale:** Phase 2 and 3 establish that the shared fragments work. Now extract the alias data from `exact_zsh/40-aliases.zsh` into `.chezmoidata.toml` so zsh is also a consumer of the single source. This is last because it touches the working zsh config — doing it last minimizes regression risk.
**Delivers:** Unified alias source — `40-aliases.zsh` either generated from `.chezmoidata.toml` or reduced to zsh-only aliases with shared data sourced from the common registry. All three shells draw from the same data.
**Implements:** Non-destructive zsh preservation + alias deduplication
**Avoids:** Alias drift between shells (Architecture Anti-Pattern 2)

### Phase Ordering Rationale

- Template infrastructure must precede all shell-specific content because chezmoi fails to render templates that include non-existent fragments
- PowerShell before Git Bash because PS has more unique pitfalls (encoding, path mapping, `function` syntax) — proving the harder case first validates the template design
- Zsh alignment is last because it is the riskiest change to existing working config and can be deferred without blocking Windows functionality
- OS gating (`.chezmoiignore`) should be created in Phase 1 to prevent accidental Linux deployment of Windows files during development

### Research Flags

Phases likely needing deeper research during planning:
- **Phase 2:** The OneDrive `$PROFILE` path issue is machine-specific — planning should include a verification step on the actual target Windows machine before committing to a path strategy. Also verify current `mise activate pwsh` syntax against latest mise docs (old `Invoke-Expression (mise activate powershell)` form may be deprecated).
- **Phase 3:** SSH agent configuration depends on whether Windows OpenSSH service is running and `init.ps1` has been executed — planning should confirm Windows setup preconditions.

Phases with standard patterns (skip research-phase):
- **Phase 1:** chezmoi template infrastructure is fully documented; `.chezmoidata.toml` and `.chezmoitemplates/` patterns are stable and well-sourced
- **Phase 4:** Zsh config extraction is mechanical — the alias data format is determined by Phase 1 work; no new research needed

---

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | All patterns verified against official chezmoi docs and existing repo files (`20-exports.zsh.tmpl`, `dot_gitconfig.tmpl`). No new dependencies required. |
| Features | HIGH | Feature set is well-scoped; clear P1/P2/P3 prioritization. Linux-only alias exclusion list is explicit and cross-referenced against `PROJECT.md`. |
| Architecture | HIGH | Component boundaries verified against chezmoi official docs + direct repo inspection. Build order dependencies are clear. |
| Pitfalls | HIGH | Most pitfalls verified against official docs and GitHub issues. SSH agent pitfall cross-referenced with existing `init.ps1` setup. |

**Overall confidence:** HIGH

### Gaps to Address

- **ejson on Windows (EJSON_KEYDIR):** The research confirms ejson is already a precondition per `PROJECT.md` but does not verify the exact key discovery path on Windows. Before Phase 2 implementation, confirm `EJSON_KEYDIR` environment variable is set correctly on the Windows machine or that the chezmoi config handles key location.
- **OneDrive path on target machine:** Whether `$PROFILE` resolves to standard `Documents` or to `OneDrive\Documents` is machine-specific and cannot be determined from the repo. This must be checked on the actual Windows machine before the PowerShell profile is deployed.
- **mise activation syntax currency:** The research notes that `Invoke-Expression (mise activate powershell)` may be the old form. The current recommended form is `(&mise activate pwsh) | Out-String | Invoke-Expression`. Verify against current mise docs at implementation time.
- **`if_command_exists` in Git Bash:** The zsh helper `if_command_exists` from `30-commands.zsh` cannot be called in the generated `.bashrc`. If tool-availability guards are needed in Git Bash, a POSIX inline form (`command -v tool >/dev/null 2>&1`) must be used instead.

---

## Sources

### Primary (HIGH confidence)
- [Chezmoi Templating User Guide](https://www.chezmoi.io/user-guide/templating/) — template variables, OS conditions, `.chezmoidata`, `.chezmoitemplates`
- [Chezmoi `.chezmoiignore` Reference](https://www.chezmoi.io/reference/special-files/chezmoiignore/) — exact ignore syntax, OS gating
- [Chezmoi `.chezmoitemplates/` Reference](https://www.chezmoi.io/reference/special-directories/chezmoitemplates/) — shared fragments, nil context caveat
- [Chezmoi `ejsonDecrypt` Reference](https://www.chezmoi.io/reference/templates/ejson-functions/ejsonDecrypt/) — signature, caching, return type
- [Chezmoi Manage Machine-to-Machine Differences](https://www.chezmoi.io/user-guide/manage-machine-to-machine-differences/) — OS-specific deployment patterns
- Existing repo file `exact_zsh/20-exports.zsh.tmpl` — confirmed `joinPath .chezmoi.sourceDir | ejsonDecrypt` pattern and `.gemini_api_key` field name
- Existing repo file `dot_gitconfig.tmpl` — confirmed `{{ if eq .chezmoi.os "windows" }}` pattern
- [PowerShell about_Aliases (PS 7.5)](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_aliases?view=powershell-7.5) — `Set-Alias` limitations
- [PowerShell about_Character_Encoding](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_character_encoding?view=powershell-7.4) — UTF-8 BOM behavior

### Secondary (MEDIUM confidence)
- [GitHub Discussion #4228 — Path mapping limitation](https://github.com/twpayne/chezmoi/discussions/4228) — OneDrive/Documents path variability confirmed as known limitation
- [GitHub Issue #2138 — OneDrive non-portable paths in chezmoi](https://github.com/twpayne/chezmoi/issues/2138) — OneDrive Documents path issue
- [GitHub Issue #2125 — `.chezmoitemplates` nil data](https://github.com/twpayne/chezmoi/issues/2125) — nil data context pitfall confirmed
- [SSH agent setup for Git Bash / Windows](https://gist.github.com/JanTvrdik/33df5554d981973fce02) — Windows OpenSSH service integration pattern
- [mise Getting Started docs — PowerShell activation](https://mise.jdx.dev/getting-started.html) — activation syntax
- [Cross-platform dotfiles patterns](https://calvin.me/cross-platform-dotfiles/) — general patterns reference

### Tertiary (MEDIUM-LOW confidence)
- [Chezmoi Windows user guide](https://www.chezmoi.io/user-guide/machines/windows/) — Windows-specific notes (PS profile path not covered)
- [PowerShell Set-Alias limitation — GitHub Issue #11310](https://github.com/PowerShell/PowerShell/issues/11310) — `Set-Alias` cannot take arguments

---
*Research completed: 2026-03-14*
*Ready for roadmap: yes*

# Architecture Research

**Domain:** Cross-shell dotfiles configuration (chezmoi)
**Researched:** 2026-03-14
**Confidence:** HIGH (chezmoi official docs + direct inspection of existing repo)

## Standard Architecture

### System Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                     SOURCE STATE (chezmoi repo)                      │
│                  ~/.local/share/chezmoi/                             │
├─────────────────────────────────────────────────────────────────────┤
│  ┌──────────────────────┐    ┌───────────────────────────────────┐  │
│  │  .chezmoidata.toml   │    │  .chezmoitemplates/               │  │
│  │  (shared alias data) │    │  (reusable template fragments)    │  │
│  │  keys.ejson          │    │  aliases_shared                   │  │
│  │  (secrets)           │    │  env_vars_shared                  │  │
│  └──────────┬───────────┘    └────────────────┬──────────────────┘  │
│             │ data context                     │ include/template     │
│             ▼                                  ▼                      │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐  │
│  │ exact_zsh/       │  │ Documents/        │  │ dot_bashrc.tmpl  │  │
│  │ 20-exports.zsh   │  │ PowerShell/       │  │ (Git Bash /      │  │
│  │ .tmpl            │  │ Microsoft.        │  │ Windows only)    │  │
│  │ 40-aliases.zsh   │  │ PowerShell_       │  │                  │  │
│  │ (zsh-only, no    │  │ profile.ps1.tmpl  │  │                  │  │
│  │  template today) │  │ (Windows only)    │  │                  │  │
│  └──────────┬───────┘  └────────┬──────────┘  └────────┬─────────┘  │
└─────────────┼───────────────────┼─────────────────────┼─────────────┘
              │ chezmoi apply      │ chezmoi apply        │ chezmoi apply
              ▼                   ▼                      ▼
┌─────────────────────┐  ┌────────────────────────────────────────────┐
│  TARGET: Linux       │  │      TARGET: Windows                       │
│  ~/zsh/*.zsh         │  │  ~\Documents\PowerShell\                   │
│  (sourced by .zshrc) │  │    Microsoft.PowerShell_profile.ps1        │
│                      │  │  ~/.bashrc  (Git Bash, Windows)            │
└─────────────────────┘  └────────────────────────────────────────────┘
```

### Component Responsibilities

| Component | Responsibility | Current State |
|-----------|----------------|---------------|
| `.chezmoidata.toml` | Structured shared data — alias groups, env var definitions, accessible as `.aliasGroups.*` in any template | Does not exist yet; must be created |
| `.chezmoitemplates/` | Reusable template fragments; included with `{{ template "name" . }}` — receives full data context | Does not exist yet; must be created |
| `exact_zsh/40-aliases.zsh` | Zsh alias definitions — currently plain file, not a template | Exists; alias data to be extracted from here |
| `exact_zsh/20-exports.zsh.tmpl` | Zsh environment variables — already a template using ejson | Exists and working |
| `Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl` | Windows PowerShell profile; rendered only on Windows via `.chezmoiignore` | Does not exist; must be created |
| `dot_bashrc.tmpl` | Git Bash `.bashrc` for Windows; replaces current `dot_bashrc` (marked "NOT USED") | Exists as plain file; convert to `.tmpl` |
| `.chezmoiignore` | OS-level gating — excludes `Documents/` on non-Windows, gates Windows-only files | Does not exist; must be created |
| `keys.ejson` | Secrets (GEMINI_API_KEY etc.) — ejson-encrypted, decrypted at template render time | Exists and working |

## Recommended Project Structure

```
~/.local/share/chezmoi/
├── .chezmoidata.toml              # NEW: shared alias groups + env var data
├── .chezmoitemplates/
│   ├── aliases_shared             # NEW: alias definitions in neutral data form
│   └── env_vars_shared            # NEW: shared env var block (optional)
├── .chezmoiignore                 # NEW: OS-conditional file gating
│
├── exact_zsh/
│   ├── 40-aliases.zsh             # MODIFY: source from .chezmoidata or keep zsh-only
│   └── 20-exports.zsh.tmpl        # KEEP: already working, add shared vars
│
├── Documents/                     # NEW directory (Windows path)
│   └── PowerShell/
│       └── Microsoft.PowerShell_profile.ps1.tmpl   # NEW: Windows PS profile
│
├── dot_bashrc.tmpl                # MODIFY: convert from plain to template (Git Bash)
│
└── keys.ejson                     # KEEP: secrets, unchanged
```

### Structure Rationale

- **`.chezmoidata.toml`:** Single source of truth for alias data. Accessible as `.aliasGroups.navigation`, `.aliasGroups.git`, etc. in all `.tmpl` files. Templates in `.chezmoitemplates/` render this data into shell-specific syntax.
- **`.chezmoitemplates/`:** Template fragments for shared alias/env blocks. Each shell file includes the relevant fragment and passes the data context (`. `) explicitly. This avoids duplicating alias lists in three separate files.
- **`Documents/PowerShell/`:** chezmoi maps the repo's `Documents/` directory to the user's `Documents` folder on Windows (`$HOME/Documents`). The `.chezmoiignore` file excludes this directory on Linux, so it only deploys on Windows.
- **`.chezmoiignore`:** The only mechanism chezmoi provides for deploying files to different OSes at the filename level. Template conditions (`{{ if eq .chezmoi.os ... }}`) handle content differences; `.chezmoiignore` handles presence/absence of entire files.

## Architectural Patterns

### Pattern 1: `.chezmoidata.toml` as Alias Registry

**What:** Aliases are declared once as structured TOML data. Templates iterate over the data to emit the correct syntax for each shell.

**When to use:** Any alias or env var that appears in more than one shell. Linux-only aliases (yay, brewfile, bundleantidote, updatedesktopdb) stay in `exact_zsh/40-aliases.zsh` as plain zsh — they are not in the shared data.

**Trade-offs:** Adds indirection — you edit `.chezmoidata.toml` not the shell files directly. Pays off when there are 3+ shells; for 2 shells the value is smaller but the pattern is correct for future growth.

**Example:**
```toml
# .chezmoidata.toml

[aliasGroups.navigation]
  [aliasGroups.navigation.dotdot]
  cmd = "cd .."
  [aliasGroups.navigation.dotdotdot]
  cmd = "cd ../.."

[aliasGroups.git]
  [aliasGroups.git.lzg]
  cmd = "lazygit"

[sharedEnv]
  LC_ALL = "en_US.UTF-8"
  EDITOR = "vim"
  VISUAL = "code"
```

Then in `.chezmoitemplates/aliases_posix`:
```
{{ range $name, $alias := .aliasGroups.navigation -}}
alias {{ $name }}='{{ $alias.cmd }}'
{{ end -}}
```

And in `.chezmoitemplates/aliases_powershell`:
```
{{ range $name, $alias := .aliasGroups.navigation -}}
function {{ $name }} { {{ $alias.cmd }} }
{{ end -}}
```

### Pattern 2: `.chezmoiignore` for OS File Gating

**What:** Files and directories listed in `.chezmoiignore` (which is itself a template) are excluded from the target state. This is the correct mechanism for "deploy this file only on Windows."

**When to use:** Any file that should not exist on a given OS — the PowerShell profile on Linux, the Git Bash `.bashrc` on Linux (if kept Windows-only).

**Trade-offs:** The only alternative is template conditions inside every managed file, which is messy for files that are entirely absent on one OS.

**Example:**
```
# .chezmoiignore
{{- if ne .chezmoi.os "windows" }}
Documents/
{{- end }}
```

### Pattern 3: Windows PowerShell Profile Path Resolution

**What:** chezmoi maps its `Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl` source path to `~\Documents\PowerShell\Microsoft.PowerShell_profile.ps1` on Windows. This is a direct path mapping — chezmoi treats `Documents/` in the source as `$HOME/Documents/` in the target (same as it treats `dot_` as `.`).

**When to use:** Always — this is the idiomatic chezmoi approach for the PowerShell profile. No special handling needed beyond the `Documents/` directory name.

**Trade-offs:** OneDrive can redirect `Documents` to a non-standard path on managed Windows machines. This is a known chezmoi issue (Discussion #2138). For personal use without OneDrive sync, the direct mapping is reliable. If OneDrive is present, `rewriteTargetPaths` in `chezmoi.toml.tmpl` can remap the path dynamically using `env "USERPROFILE"` or registry lookup.

**Example source path:**
```
~/.local/share/chezmoi/Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl
```
Maps to target:
```
C:\Users\mayurifag\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
```

## Data Flow

### Config Render Flow (chezmoi apply)

```
keys.ejson
    │ ejsonDecrypt()
    ▼
Decrypted secrets (GEMINI_API_KEY, ...)
    │
    ├──────────────────────────┐
    ▼                          ▼
.chezmoidata.toml         .chezmoi.os / .chezmoi.* (built-in)
    │ template data             │ system variables
    └──────────┬────────────────┘
               │ merged context (.)
               ▼
    .chezmoitemplates/aliases_posix
    .chezmoitemplates/aliases_powershell
    .chezmoitemplates/env_vars_shared
               │ {{ template "..." . }}
               ├──────────────────────────────────────────┐
               ▼                                          ▼
    exact_zsh/20-exports.zsh.tmpl            Documents/PowerShell/
    exact_zsh/40-aliases.zsh                   Microsoft.PowerShell_profile.ps1.tmpl
    (zsh-only aliases stay here)              dot_bashrc.tmpl
               │                                          │
               ▼                                          ▼
    ~/zsh/20-exports.zsh (Linux)         ~\Documents\PowerShell\
    ~/zsh/40-aliases.zsh (Linux)           Microsoft.PowerShell_profile.ps1 (Windows)
                                          ~/.bashrc (Git Bash, Windows)
```

### Key Data Flows

1. **Shared alias data to PowerShell:** `.chezmoidata.toml` → template context → `.chezmoitemplates/aliases_powershell` → included in PS profile template → rendered as `function name { cmd }` syntax.

2. **Shared alias data to Git Bash:** Same `.chezmoidata.toml` → `.chezmoitemplates/aliases_posix` → included in `dot_bashrc.tmpl` → rendered as `alias name='cmd'` syntax.

3. **Secrets to all shells:** `keys.ejson` is decrypted once per `chezmoi apply` run. The decrypted value is available in any `.tmpl` file via `{{ (joinPath .chezmoi.sourceDir "keys.ejson" | ejsonDecrypt).gemini_api_key }}`. This expression is copied to each shell's template that needs secrets.

4. **OS gating:** `.chezmoiignore` evaluated first. If OS is not Windows, `Documents/` subtree is excluded entirely before any template rendering for those files.

### Build Order (Dependency Graph)

chezmoi does not have explicit "build phases" — all templates are rendered in a single `chezmoi apply` pass. The logical dependency order for implementation is:

```
1. .chezmoidata.toml              ← defines the data
       ↓
2. .chezmoitemplates/             ← consumes data, produces shell-specific fragments
       ↓
3. dot_bashrc.tmpl                ← includes shared fragment (Git Bash)
   Documents/PowerShell/          ← includes shared fragment (PowerShell)
       ↓
4. .chezmoiignore                 ← gates files by OS (no data dependency, but
                                      must exist before files can be tested)
       ↓
5. exact_zsh/ (no changes needed) ← zsh already works; shared aliases extracted
                                      from 40-aliases.zsh into .chezmoidata.toml
```

Steps 1-2 must come before 3 because templates that `include` fragments fail to render if the fragment does not exist. Steps 3-4 can be done in parallel. Step 5 is the cleanup — extracting shared alias data out of the existing zsh file.

## Anti-Patterns

### Anti-Pattern 1: Template Conditions for File Presence

**What people do:** Put the entire PowerShell profile inside a `.tmpl` file wrapped in `{{ if eq .chezmoi.os "windows" }}...{{ end }}` and deploy it everywhere (e.g., as `dot_config/powershell/profile.ps1.tmpl`).

**Why it's wrong:** The file still gets rendered on Linux (producing an empty file at `~/.config/powershell/profile.ps1`). Linux systems do not have PowerShell in the standard path structure. You also lose the correct Windows target path.

**Do this instead:** Put the file at `Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl` in the source so chezmoi maps it to the correct Windows path, and exclude it on Linux via `.chezmoiignore`.

### Anti-Pattern 2: Duplicating Alias Lists in Each Shell File

**What people do:** Copy-paste the same alias definitions into `40-aliases.zsh`, `profile.ps1`, and `.bashrc`, then update them in three places.

**Why it's wrong:** Drift. The alias lists get out of sync immediately. Every change requires three edits.

**Do this instead:** Extract shared aliases into `.chezmoidata.toml` as structured data. Generate all three shell files from that single source using templates in `.chezmoitemplates/`.

### Anti-Pattern 3: Hardcoding Secrets in Template Data

**What people do:** Put API keys directly in `.chezmoidata.toml` (which is committed to the repo).

**Why it's wrong:** Secrets end up in git history.

**Do this instead:** Keep secrets in `keys.ejson` (encrypted). Reference them in `.tmpl` files via `ejsonDecrypt`. `.chezmoidata.toml` holds only non-secret configuration data.

### Anti-Pattern 4: Using `.chezmoidata.toml` Templates

**What people do:** Try to use `{{ .chezmoi.os }}` conditions inside `.chezmoidata.toml` to make the data itself OS-conditional.

**Why it's wrong:** `.chezmoidata` files do not support Go template syntax — they are static data. Template evaluation is not supported in data files.

**Do this instead:** Put OS conditions in the `.chezmoitemplates/` fragments that consume the data, not in the data itself. The same alias data is always loaded; the template decides whether to emit it as `alias` or as `function`.

## Integration Points

### Internal Boundaries

| Boundary | Communication | Notes |
|----------|---------------|-------|
| `.chezmoidata.toml` → shell templates | Go template context (`.`) passed via `{{ template "name" . }}` | Context must be passed explicitly — omitting `.` gives nil context |
| `keys.ejson` → any `.tmpl` file | `ejsonDecrypt` template function, called inline | Runs at apply time; ejson private key must be present on the machine |
| `.chezmoiignore` → file deployment | File inclusion/exclusion before template rendering | OS check happens at apply time via `.chezmoi.os` in the ignore file |
| `exact_zsh/40-aliases.zsh` → `.chezmoidata.toml` | One-time migration — data extracted, file becomes a consumer | After migration, `40-aliases.zsh` either `include`s the shared data or keeps zsh-only aliases only |

### External Dependencies

| Dependency | Used By | Notes |
|------------|---------|-------|
| ejson private key (`~/.ejson/keys`) | Any template calling `ejsonDecrypt` | Must exist on Windows machine before `chezmoi apply` — documented in `windows/INSTRUCTION.md` |
| mise | PowerShell profile, Git Bash `.bashrc` | `Invoke-Expression (mise activate powershell)` / `eval "$(mise activate bash)"` — mise must be installed first |
| zoxide | PowerShell profile only | `Invoke-Expression (& { (zoxide init powershell | Out-String) })` — zoxide must be installed first |
| starship | PowerShell profile only | `Invoke-Expression (&starship init powershell)` — starship must be installed first |

## Sources

- [chezmoi: Manage machine-to-machine differences](https://www.chezmoi.io/user-guide/manage-machine-to-machine-differences/) — template conditions, `.chezmoiignore`
- [chezmoi: Windows user guide](https://www.chezmoi.io/user-guide/machines/windows/) — Windows-specific considerations
- [chezmoi: Templating](https://www.chezmoi.io/user-guide/templating/) — `.chezmoidata`, `.chezmoitemplates`, `includeTemplate`
- [chezmoi: `.chezmoitemplates/` reference](https://www.chezmoi.io/reference/special-directories/chezmoitemplates/) — how shared templates work, nil context caveat
- [chezmoi: `.chezmoidata/` reference](https://www.chezmoi.io/reference/special-directories/chezmoidata/) — structured data files
- [chezmoi: Source state attributes](https://www.chezmoi.io/reference/source-state-attributes/) — filename prefix conventions
- [chezmoi Discussion #4228: How to map one path to another](https://github.com/twpayne/chezmoi/discussions/4228) — PowerShell profile path mapping
- [chezmoi Issue #2138: OneDrive PC folder backup causes non-portable paths](https://github.com/twpayne/chezmoi/issues/2138) — OneDrive Documents path issue

---
*Architecture research for: Cross-shell dotfiles (chezmoi)*
*Researched: 2026-03-14*

# Stack Research

**Domain:** Cross-shell dotfiles configuration sharing via chezmoi templates
**Researched:** 2026-03-14
**Confidence:** HIGH (chezmoi official docs verified; ejsonDecrypt syntax confirmed against live repo usage)

---

## Recommended Stack

### Core Technologies

| Technology | Version | Purpose | Why Recommended |
|------------|---------|---------|-----------------|
| chezmoi templates (`text/template`) | Current (2.x) | Generate per-shell config files from a single source | Native to this repo; zero runtime overhead — files are rendered at `chezmoi apply` time, not at shell startup |
| `.chezmoitemplates/` shared blocks | Built-in | Reusable template fragments shared across multiple target files | Lets shared alias/env-var definitions live in one place and be `{{ template "..." . }}`-included into shell-specific files |
| `.chezmoiignore` OS gating | Built-in | Deploy a file only on Windows or only on Linux | The idiomatic chezmoi way to conditionally exclude entire files/directories per OS — avoids adding OS guards to every file |
| ejson (`keys.ejson`) | Already in repo | Encrypt API keys (GEMINI_API_KEY) in the git repo | Already used in `20-exports.zsh.tmpl`; same pattern applies to PowerShell and Git Bash profiles |

### No New Dependencies Required

This project requires no new tooling beyond what chezmoi already provides. The entire stack is:
- chezmoi template engine (Go `text/template` + sprig functions)
- The existing `keys.ejson` file and ejson key
- New source files following chezmoi naming conventions

---

## Key Technical Patterns

### Pattern 1: OS Conditional in File Content

Use `{{ if eq .chezmoi.os "windows" }}` inside `.tmpl` files when a single target path contains OS-specific content (e.g., `dot_gitconfig.tmpl` already does this).

```
{{- if eq .chezmoi.os "windows" }}
$env:GEMINI_API_KEY = "{{ (joinPath .chezmoi.sourceDir "keys.ejson" | ejsonDecrypt).gemini_api_key }}"
{{- end }}
```

This pattern is appropriate when the target **path** is the same on all OSes but content differs.

### Pattern 2: OS Gating via `.chezmoiignore` (Recommended for this project)

Use `.chezmoiignore` to prevent chezmoi from deploying Windows-specific files on Linux and vice versa. This is the correct approach when the **target path itself** only exists on one OS.

```
{{- if ne .chezmoi.os "windows" }}
Documents/PowerShell/Microsoft.PowerShell_profile.ps1
{{- end }}
```

Logic is inverted: chezmoi deploys everything by default, so you must say "ignore this file when NOT on Windows" rather than "deploy only on Windows."

This is the idiomatic approach confirmed by official chezmoi docs and community usage.

### Pattern 3: `joinPath .chezmoi.sourceDir` for ejsonDecrypt

The `ejsonDecrypt` function takes a file path — use `joinPath .chezmoi.sourceDir "keys.ejson"` to build an absolute path. This is exactly what `20-exports.zsh.tmpl` already does:

```
{{ (joinPath .chezmoi.sourceDir "keys.ejson" | ejsonDecrypt).gemini_api_key }}
```

The decrypted object is a map; access fields with Go dot notation. The result is cached — calling `ejsonDecrypt` multiple times in one apply does not re-decrypt.

### Pattern 4: `.chezmoitemplates/` for Shared Alias/Env-Var Blocks

Place shared data (alias definitions in POSIX syntax, env var assignments) in `.chezmoitemplates/`. Each shell-specific profile template then includes the appropriate block.

```
# .chezmoitemplates/shared-aliases-posix.tmpl
alias ..='cd ..'
alias cz='chezmoi'
# ... more POSIX-compatible aliases

# .chezmoitemplates/shared-envvars.tmpl
export EDITOR=vim
export VISUAL=code
export LC_ALL=en_US.UTF-8
export GEMINI_API_KEY="{{ (joinPath .chezmoi.sourceDir "keys.ejson" | ejsonDecrypt).gemini_api_key }}"
```

Include in Git Bash `.bashrc` template:
```
{{- template "shared-aliases-posix.tmpl" . -}}
{{- template "shared-envvars.tmpl" . -}}
```

Pass `.` (dot) explicitly — without it, the shared template runs with nil context and `.chezmoi.sourceDir` will be unavailable.

### Pattern 5: PowerShell Aliases as Functions

PowerShell does not support `alias name='...'` syntax for aliases with arguments. Simple aliases use `Set-Alias`; anything with arguments requires `function`:

```powershell
# Simple alias
Set-Alias -Name cz -Value chezmoi

# Alias with logic or arguments — must be a function
function gp {
    if (-not (git config "branch.$(git symbolic-ref --short HEAD).merge")) {
        git push -u origin (git symbolic-ref --short HEAD)
    } else {
        git push
    }
}
```

The `.chezmoitemplates/` file for PowerShell aliases **must** emit `function` blocks, not POSIX `alias` statements.

---

## File Naming Conventions

### Source Path → Target Path Mapping

| Source Path (in `~/.local/share/chezmoi/`) | Target Path (deployed to) | OS |
|---------------------------------------------|---------------------------|----|
| `dot_bashrc.tmpl` | `~/.bashrc` | Windows (Git Bash home) |
| `Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl` | `~/Documents/PowerShell/Microsoft.PowerShell_profile.ps1` | Windows only |
| `exact_zsh/20-exports.zsh.tmpl` | `~/.zsh/20-exports.zsh` | Linux (already working) |

### PowerShell Profile: Conventional Path

PowerShell 7+ (`pwsh`) on Windows looks for the profile at:
```
$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
```

The chezmoi source path that maps to this is:
```
Documents/PowerShell/Microsoft.PowerShell_profile.ps1.tmpl
```

Note: `Documents` is NOT prefixed with `dot_` because it is not a hidden directory. Chezmoi maps the source directory verbatim for non-hidden paths.

**The OneDrive trap:** On many Windows machines, Microsoft redirects `~/Documents` to `~/OneDrive/Documents`. This means `$PROFILE` may resolve to a path outside `$HOME\Documents`. This is a known chezmoi limitation — native path remapping does not exist. The practical mitigation for this repo is to use the standard `~/Documents/PowerShell/` path (which works when OneDrive sync is configured to keep files on device) and document the workaround.

### Git Bash `.bashrc`: Conventional Path

Git Bash on Windows resolves `~` to `C:\Users\<username>`. It reads `~/.bashrc` on startup. The existing `dot_bashrc` source file in this repo already maps to `~/.bashrc` — no new file path is needed. The file will simply be converted from static to templated (`dot_bashrc.tmpl`).

---

## ejsonDecrypt Reference

| Aspect | Detail | Confidence |
|--------|--------|------------|
| Function name | `ejsonDecrypt` | HIGH — official docs |
| Signature | `ejsonDecrypt filePath` | HIGH — official docs |
| Path type | Absolute path recommended; use `joinPath .chezmoi.sourceDir "keys.ejson"` | HIGH — pattern confirmed in existing `20-exports.zsh.tmpl` |
| Return type | Go map — access keys with `.key_name` dot notation | HIGH — official docs + live example |
| Caching | Result cached per apply run — safe to call multiple times | HIGH — official docs |
| Key name for Gemini | `gemini_api_key` | HIGH — confirmed in `keys.ejson` |
| Windows compatibility | ejson must be installed and EJSON_KEYDIR set on Windows — assumed precondition per PROJECT.md | MEDIUM — no verification done |

---

## `.chezmoiignore` Gating Strategy

The complete OS-gating for this project should be:

```
{{- if ne .chezmoi.os "windows" }}
Documents/PowerShell/Microsoft.PowerShell_profile.ps1
{{- end }}
```

The `dot_bashrc` (Git Bash config) does NOT need gating — `~/.bashrc` is harmless on Linux even if populated, and it is already in the repo. However, if the file contains Windows-specific content, add gating:

```
{{- if ne .chezmoi.os "linux" }}
.bashrc
{{- end }}
```

For the current zsh files: they live in `exact_zsh/` which already exists only on Linux (no Windows zsh). No additional gating is needed unless zsh is ever installed on Windows.

---

## What NOT to Use

| Avoid | Why | Use Instead |
|-------|-----|-------------|
| Runtime shell parsing (e.g., sourcing a shared `.sh` file from both shells) | Requires runtime compatibility across shells; breaks if syntax differs; defeats the purpose of chezmoi templates | chezmoi template rendering at apply time — files are pre-rendered per shell |
| `{{ if eq .chezmoi.os "windows" }}` inside every zsh file | Zsh files are Linux-only; adding Windows guards is noise and fragile | `.chezmoiignore` or OS-specific source directories |
| Storing aliases in `.chezmoidata.toml` as TOML data | Aliases are multiline, contain special chars, and have shell-specific syntax — TOML data is better for scalar config values | `.chezmoitemplates/` text blocks that are included verbatim |
| PowerShell `Set-Alias` for all aliases | `Set-Alias` only maps one command name to another; cannot alias complex commands or commands with arguments | PowerShell `function` blocks for anything non-trivial |
| Nesting `{{ if eq .chezmoi.os "windows" }}` in `.chezmoitemplates/` files without passing context | Templates in `.chezmoitemplates/` execute with nil data by default — `.chezmoi.os` will be unavailable | Always pass `.` when including: `{{ template "name.tmpl" . }}` |
| ejsonDecrypt with relative path (e.g., `ejsonDecrypt "keys.ejson"`) | Path resolution behavior is not explicitly guaranteed to be relative to source dir | Use `joinPath .chezmoi.sourceDir "keys.ejson" \| ejsonDecrypt` — matches existing repo pattern |

---

## Stack Patterns by Variant

**For env vars shared across all shells (EDITOR, LC_ALL, GEMINI_API_KEY):**
- Define once in `.chezmoitemplates/shared-envvars-posix.tmpl` (POSIX `export` syntax)
- Create a separate `.chezmoitemplates/shared-envvars-ps1.tmpl` for PowerShell `$env:VAR =` syntax
- Include the appropriate block in each shell's profile template

**For aliases that map cleanly to both POSIX and PowerShell:**
- Define POSIX version in `.chezmoitemplates/shared-aliases-posix.tmpl`
- Define PowerShell version (as function blocks) in `.chezmoitemplates/shared-aliases-ps1.tmpl`
- Do NOT attempt to auto-translate — maintain two explicit template files

**For Linux-only aliases (yay, bundleantidote, brewfile, updatedesktopdb):**
- Keep in `exact_zsh/40-aliases.zsh` as-is — no template needed
- Do not add these to any shared `.chezmoitemplates/` block

**For Windows-only content:**
- Add `{{ if ne .chezmoi.os "windows" }}` gate to `.chezmoiignore` for that file
- Do not add OS guards inside the file itself unless content is genuinely mixed

---

## Version Compatibility

| Component | Version | Notes |
|-----------|---------|-------|
| chezmoi | 2.x (current) | Template functions including `ejsonDecrypt` and `joinPath` available since early 2.x |
| Go `text/template` | Built into chezmoi | No separate install; sprig functions also available |
| ejson | Any (Shopify ejson) | Must be installed system-wide and EJSON_KEYDIR set; already assumed working on Linux per repo state |
| PowerShell | 7+ (`pwsh`) preferred | `$PROFILE` path is `~/Documents/PowerShell/Microsoft.PowerShell_profile.ps1`; PS5 uses `~/Documents/WindowsPowerShell/` — target PS7 path |

---

## Sources

- [Chezmoi Templating User Guide](https://www.chezmoi.io/user-guide/templating/) — Template variables, OS conditions, whitespace control — HIGH confidence
- [Chezmoi Manage Machine-to-Machine Differences](https://www.chezmoi.io/user-guide/manage-machine-to-machine-differences/) — `.chezmoiignore` patterns, OS-specific deployment — HIGH confidence
- [Chezmoi `.chezmoiignore` Reference](https://www.chezmoi.io/reference/special-files/chezmoiignore/) — Exact ignore syntax including negation patterns — HIGH confidence
- [Chezmoi `.chezmoitemplates/` Reference](https://www.chezmoi.io/reference/special-directories/chezmoitemplates/) — Shared template blocks, `template` action, nil context caveat — HIGH confidence
- [Chezmoi `ejsonDecrypt` Reference](https://www.chezmoi.io/reference/templates/ejson-functions/ejsonDecrypt/) — Signature, caching, return type — HIGH confidence
- [Chezmoi ejson User Guide](https://www.chezmoi.io/user-guide/password-managers/ejson/) — Full ejson integration workflow — HIGH confidence
- [Chezmoi Windows User Guide](https://www.chezmoi.io/user-guide/machines/windows/) — Windows-specific scripting — MEDIUM confidence (PS profile path not covered there)
- [GitHub Discussion #4228 — Path mapping limitation](https://github.com/twpayne/chezmoi/discussions/4228) — OneDrive/Documents path variability confirmed as known limitation — MEDIUM confidence
- Existing repo file `exact_zsh/20-exports.zsh.tmpl` — Confirmed `joinPath .chezmoi.sourceDir | ejsonDecrypt` pattern and `.gemini_api_key` field name — HIGH confidence (live source)
- Existing repo file `dot_gitconfig.tmpl` — Confirmed `{{ if eq .chezmoi.os "windows" }}` pattern used in this repo — HIGH confidence (live source)

---

*Stack research for: Cross-shell configuration sharing in chezmoi dotfiles*
*Researched: 2026-03-14*

# Feature Research

**Domain:** Cross-shell dotfiles configuration (zsh / PowerShell / Git Bash via chezmoi templates)
**Researched:** 2026-03-14
**Confidence:** HIGH

## Feature Landscape

### Table Stakes (Users Expect These)

Features that must exist or the cross-shell setup fails its core purpose. Missing any of these means the config either doesn't apply, silently diverges between shells, or breaks on deployment.

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| Shared alias rendering per-shell | Core value proposition — aliases defined once, never manually duplicated | MEDIUM | zsh uses `alias x=…`, PowerShell requires `function`/`Set-Alias`, Git Bash uses POSIX `alias`. Must be generated separately per-shell via chezmoi templates. |
| Shared env var rendering per-shell | `EDITOR`, `LC_ALL`, `GEMINI_API_KEY`, PATH additions — must be consistent everywhere | MEDIUM | PowerShell uses `$env:VAR = …`, POSIX shells use `export VAR=…`. Chezmoi template conditionals handle this. |
| PATH additions (safe, guarded) | Tools like mise, cargo, local bin won't be found without PATH | LOW | Guard with existence checks (`if [[ -d … ]]` in bash/zsh; `if (Test-Path …)` in PS). Paths differ by OS — Windows uses `~\AppData\…`, Linux uses `~/.local/bin`. |
| mise activation | Runtime version manager must activate in every shell for tools to work | LOW | `eval "$(mise activate zsh)"`, `eval "$(mise activate bash)"`, `Invoke-Expression (mise activate powershell)` — already working in all three; must be preserved |
| OS-conditional deployment | PowerShell profile only on Windows; Git Bash `.bashrc` only on Windows; zsh files only on Linux | LOW | Chezmoi `.chezmoi.os` conditions already in use. This is the scaffolding everything else depends on. |
| SSH agent auto-start in Git Bash | Git operations fail silently without a running ssh-agent on Windows | LOW | Standard Git Bash pattern: check if agent is running, start if not, add key. Must be in `.bashrc`. |
| Secrets via ejson (not plaintext) | `GEMINI_API_KEY` and future API keys must never appear in committed files | LOW | Already established pattern in `20-exports.zsh.tmpl`. PowerShell and Git Bash profiles must use same ejson decryption at chezmoi template time. |
| Non-destructive zsh preservation | Existing zsh config must keep working unchanged | LOW | Do not modify numbered `exact_zsh/` files. Extract shared data (aliases, env vars) into a new shared source that zsh also sources, OR generate the existing files from templates. |

### Differentiators (Competitive Advantage)

Features that make this setup meaningfully better than manually-maintained per-shell configs, beyond the basic sharing.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| Starship prompt on PowerShell | Consistent, informative prompt matching the Linux experience; already installed on Windows per winget setup | LOW | One line in PS profile: `Invoke-Expression (&starship init powershell)`. No cross-shell complexity. |
| zoxide activation on PowerShell | Smart directory navigation (`z`) works on Windows too — high daily-use value | LOW | `Invoke-Expression (& { (zoxide init powershell) })`. No cross-shell complexity. |
| Tool-availability guards in aliases | Aliases that depend on optional tools (eza, lazygit, docker) degrade gracefully instead of erroring | MEDIUM | In POSIX shells: `if command -v eza &>/dev/null; then …`. In PowerShell: `if (Get-Command eza -ErrorAction SilentlyContinue)`. Currently done in zsh via `if_command_exists`; same discipline needed in generated files. |
| Git alias group ported to PowerShell | `gp`, `gpf`, `grc`, `gri`, `lzg` as PS functions — git operations feel the same on Windows | LOW | Each becomes a `function gp { … }` block. Trivial per-alias, moderate in aggregate to template correctly. |
| Chezmoi shortcut aliases on PowerShell | `cz`, `czcd`, `czapply` — useful for managing dotfiles from Windows too | LOW | Straightforward PS function wrappers. Low value unless actively editing dotfiles on Windows. |
| Navigation aliases on all shells | `..`, `...`, `....` — muscle memory works everywhere | LOW | These are POSIX-identical and safe to share. In PowerShell: `function .. { Set-Location .. }` pattern. |
| Editor aliases on PowerShell | `vi`/`v` pointing to vim or code — shorthand that works on Windows | LOW | Only useful if vim/code is in PATH on Windows (it is, per Wingetfile). |

### Anti-Features (Commonly Requested, Often Problematic)

Features that seem natural to add but create real friction or breakage.

| Feature | Why Requested | Why Problematic | Alternative |
|---------|---------------|-----------------|-------------|
| Runtime shell-detection and sourcing of a shared `.sh` file | Appealing simplicity — one file, sourced by all shells at runtime | PowerShell cannot source POSIX `.sh` files. Git Bash can, but a shared file containing `export VAR=val` will fail in PowerShell. Syntax is not a common subset — it is disjoint. | Generate per-shell files at chezmoi apply time. Each shell sources only its own file. No runtime cross-shell parsing. |
| Sharing complex zsh functions cross-shell | Functions like `f()`, `make()`, `mkcd()`, `grom()` represent deep zsh-specific logic; porting them feels efficient | These use zsh-specific syntax (`[[ ]]`, `$()`, process substitution) and depend on Linux tools (xxd, jq, lsof, ntfsfix, ydotool) absent on Windows. Porting creates fragile, untested PS equivalents. | Keep complex functions zsh-only. Only share simple, tool-invocation aliases where the same binary exists on both platforms. |
| Linux-specific aliases on Windows | `y` (yay), `reboot`, `root`, `brewfile`, `bundleantidote`, `updatedesktopdb`, `fixntfs`, `cs-unban-me` seem like they could be skipped by guards | Even with guards, adding them to PS/Git Bash templates adds noise, maintenance burden, and confusion ("why is this alias here?"). Guard logic becomes the dominant complexity. | Explicitly mark these as zsh-Linux-only in the shared alias data. Include a `zsh_only: true` flag or keep them in `40-aliases.zsh` directly. |
| Identical prompt setup (starship config) across all shells | Tempting to use a shared `starship.toml` — consistent look everywhere | Not an anti-feature for the config file itself (starship.toml is already cross-shell). The anti-feature is trying to configure starship via shell exports that only work in one shell. | Use a single `dot_config/starship.toml` (already the pattern), activate per-shell with the appropriate activation command, done. |
| Sharing history between zsh and bash/PowerShell | Single history file sounds appealing | History formats are incompatible. zsh uses its own format; bash uses plain text; PowerShell uses its own XML/text hybrid. Merging causes corruption or loss. | Accept per-shell history. Keep `HISTFILE` settings in shell-specific config sections only. |
| yt-dlp / translate-shell aliases on Windows | Cross-shell feels complete if everything is shared | These tools are unlikely to be installed on Windows (not in Wingetfile). Aliases referencing absent binaries create confusing errors. Guard-only approach adds complexity for zero practical value on Windows. | Keep yt-dlp and trans aliases zsh-Linux only. |
| Functions with complex argument handling as PS aliases | `gp`, `docker-clean` have multi-statement logic — porting to PS functions feels right | PowerShell `Set-Alias` cannot pass arguments. Every such alias needs a `function` wrapper. The template complexity to generate correct `{ … }` blocks with proper PS syntax is non-trivial, especially for multi-line commands. | Use simple PS `function` blocks for the Git aliases that matter. Accept that `docker-clean` stays zsh-only (Docker on Windows uses Docker Desktop with its own UI). |
| `if_command_exists` helper function in PS/Bash | Used extensively in zsh for tool guards | `if_command_exists` is a custom zsh function defined in `30-commands.zsh`. It doesn't exist in bash or PS without explicit definition. Copying call sites without copying the function causes silent failures. | In generated bash, use `command -v "$1" >/dev/null 2>&1` inline or define a minimal version. In PS, use `Get-Command … -ErrorAction SilentlyContinue`. Don't copy the zsh helper name. |

## Feature Dependencies

```
[OS-conditional deployment]
    └──required by──> [Shared alias rendering per-shell]
    └──required by──> [Shared env var rendering per-shell]
    └──required by──> [PATH additions]
    └──required by──> [mise activation]
    └──required by──> [SSH agent auto-start in Git Bash]

[Shared alias rendering per-shell]
    └──required by──> [Tool-availability guards in aliases]
    └──required by──> [Git alias group ported to PowerShell]
    └──required by──> [Chezmoi shortcut aliases on PowerShell]
    └──required by──> [Navigation aliases on all shells]

[Secrets via ejson]
    └──required by──> [Shared env var rendering per-shell]

[mise activation]
    └──enhances──> [PATH additions]  (mise shims extend PATH)

[Starship prompt on PowerShell] ──independent──> [Shared alias rendering]
[zoxide activation on PowerShell] ──independent──> [Shared alias rendering]

[Runtime shared .sh sourcing] ──conflicts with──> [PowerShell support]
[Shared history] ──conflicts with──> [Non-destructive zsh preservation]
```

### Dependency Notes

- **OS-conditional deployment requires chezmoi template infrastructure first:** All other features depend on the skeleton — PowerShell profile file, Git Bash `.bashrc` file — being managed by chezmoi with correct OS conditions. This is Phase 1.
- **Shared alias rendering depends on alias data being extracted:** The zsh `40-aliases.zsh` must either be generated from a shared data source, or the shared data must be extracted alongside it. This determines whether zsh changes are needed at all.
- **Tool-availability guards depend on per-shell helper pattern:** Each shell needs its own idiomatic guard. These must be established before adding guarded aliases, or the aliases fail silently.
- **ejson decryption is a hard dependency for env var sharing:** `GEMINI_API_KEY` cannot appear in generated files without chezmoi's `ejsonDecrypt` function. This is already working in zsh; the pattern must be replicated exactly for other shells.
- **`if_command_exists` conflicts with Git Bash and PowerShell:** Calling this function in generated files without defining it first causes silent failures. Resolve before adding any guarded aliases.

## MVP Definition

### Launch With (v1)

Minimum viable product — the setup that eliminates manual divergence without adding new complexity.

- [ ] Chezmoi-managed PowerShell profile with: mise activation + starship + zoxide + shared env vars + core alias groups (Navigation, Git, Editor) — validates the template-generated PS profile approach
- [ ] Chezmoi-managed Git Bash `.bashrc` with: mise activation + ssh-agent auto-start + shared env vars + core alias groups (Navigation, Git) — replaces the current "NOT USED" `dot_bashrc`
- [ ] Shared env vars (EDITOR, VISUAL, LC_ALL, GEMINI_API_KEY, PATH additions) rendered correctly in all three shells via chezmoi templates
- [ ] Linux-only aliases (yay, brewfile, bundleantidote, updatedesktopdb, yt-dlp, trans) explicitly excluded from shared groups
- [ ] Existing zsh config keeps working unchanged (non-destructive)

### Add After Validation (v1.x)

Features to add once core template pipeline is proven correct.

- [ ] Docker alias group on PowerShell and Git Bash — add once Windows Docker Desktop usage is confirmed
- [ ] Chezmoi shortcut aliases on PowerShell (`cz`, `czcd`, `czapply`) — add if actively using chezmoi from Windows
- [ ] Tool-availability guards for eza on Windows — add if eza is added to Wingetfile
- [ ] Additional Git alias groups (gpf, grc, gri, lzg) on PowerShell — add if lazygit is confirmed installed on Windows

### Future Consideration (v2+)

Features to defer — low immediate value or high complexity.

- [ ] Extracting shared alias data into a structured format (TOML/YAML data file) — defer until the alias set grows large enough that duplication is painful; templates work fine for current scale
- [ ] Porting complex zsh utility functions (grom, make, f, mkcd) to PowerShell — defer; these are Linux-workflow functions with no clear Windows equivalent need
- [ ] Shared `~/.gitconfig` aliases (separate from shell aliases) — defer; git aliases are already in `.gitconfig` and work cross-platform natively via git itself

## Feature Prioritization Matrix

| Feature | User Value | Implementation Cost | Priority |
|---------|------------|---------------------|----------|
| OS-conditional PS profile + Git Bash .bashrc skeleton | HIGH | LOW | P1 |
| mise activation in PS and Git Bash | HIGH | LOW | P1 |
| Shared env vars (EDITOR, LC_ALL, GEMINI_API_KEY, PATH) | HIGH | MEDIUM | P1 |
| SSH agent auto-start in Git Bash | HIGH | LOW | P1 |
| Navigation + Git alias groups in PS and Git Bash | HIGH | MEDIUM | P1 |
| Starship + zoxide activation on PowerShell | MEDIUM | LOW | P1 |
| Tool-availability guards for optional tools | MEDIUM | MEDIUM | P2 |
| Docker alias group on Windows | MEDIUM | LOW | P2 |
| Chezmoi shortcut aliases on PowerShell | LOW | LOW | P2 |
| yt-dlp / translate-shell aliases on Windows | LOW | LOW | P3 (exclude) |
| Complex zsh function porting to PowerShell | LOW | HIGH | P3 (exclude) |
| Shared history across shells | LOW | HIGH | P3 (anti-feature) |

**Priority key:**
- P1: Must have for launch
- P2: Should have, add when possible
- P3: Nice to have or explicitly out of scope

## Competitor Feature Analysis

This is a personal dotfiles project, not a product with competitors. However, well-maintained public cross-shell dotfiles repos exhibit consistent patterns worth noting.

| Feature | renemarc/dotfiles | JohnEricson/dotfiles | This Project |
|---------|-----------------|---------------------|--------------|
| Template-generated per-shell files | Yes (chezmoi) | No (manual per-shell files) | Yes (chezmoi templates — chosen approach) |
| PowerShell support | Yes | Yes (PS5.1 + PSCore) | Yes (Windows only) |
| Git Bash support | Partial | Yes (explicitly supported) | Yes (minimal, Claude-use case) |
| zsh support | Yes | Yes | Yes (existing, non-destructive) |
| Secrets management | gitignore-based | gitignore-based | ejson (stronger) |
| Linux-specific alias exclusion | OS detection at runtime | Separate files per OS | Compile-time exclusion via chezmoi data |

**Note:** The chezmoi template compile-time approach (generate correct files, deploy to correct OS) is stronger than runtime OS detection because errors surface at `chezmoi apply` rather than at shell startup. This is the key architectural advantage of this project's approach.

## Sources

- chezmoi templating documentation: https://www.chezmoi.io/user-guide/templating/
- Cross-shell alias syntax differences: https://kevinlinxc.com/logbooks/windows-aliases/
- PowerShell aliases cannot take parameters: https://duncanlock.net/blog/2022/03/05/windows-powershell-aliases-cant-have-parameters-you-need-to-write-a-function/
- PowerShell alias with parameters pattern: https://seankilleen.com/2020/04/how-to-create-a-powershell-alias-with-parameters/
- SSH agent auto-start in Git Bash: https://gist.github.com/bsara/5c4d90db3016814a3d2fe38d314f9c23
- Cross-platform dotfiles patterns: https://calvin.me/cross-platform-dotfiles/
- JohnEricson cross-shell dotfiles (Bash/PS/Git Bash/WSL): https://github.com/JohnEricson/dotfiles
- renemarc cross-platform dotfiles: https://github.com/renemarc/dotfiles

---
*Feature research for: cross-shell dotfiles configuration (zsh / PowerShell / Git Bash)*
*Researched: 2026-03-14*

# Pitfalls Research

**Domain:** Cross-shell dotfiles configuration (chezmoi + PowerShell + Git Bash + zsh)
**Researched:** 2026-03-14
**Confidence:** HIGH (most pitfalls verified against official docs and GitHub issues)

## Critical Pitfalls

### Pitfall 1: Sub-Template Nil Data — `.chezmoi.*` Variables Invisible

**What goes wrong:**
When a shared alias/env-var template is stored in `.chezmoitemplates/` and included in multiple per-shell files, `.chezmoi.os`, `.chezmoi.homeDir`, and all other built-in variables resolve as nil. Template execution fails with: `nil data; no entry for key "chezmoi"`.

**Why it happens:**
chezmoi executes `.chezmoitemplates/` files with nil data by default. The calling template must explicitly forward its data context. Writing `{{ template "shared-aliases.tmpl" }}` instead of `{{ template "shared-aliases.tmpl" . }}` silently drops the entire data context. This is the root cause of the most common "works on my machine" failures in cross-OS dotfiles setups.

**How to avoid:**
Always include the trailing dot: `{{ template "shared-aliases.tmpl" . }}`. Verify every template invocation in the shared alias/env-var files during the initial authoring phase.

**Warning signs:**
- `chezmoi apply` error: `nil data; no entry for key "chezmoi"`
- OS-conditional blocks in shared templates always evaluate the `else` branch
- `chezmoi execute-template` works for variables directly but the generated file is wrong

**Phase to address:**
Phase 1 (shared template structure). Establish the `{{ template "..." . }}` convention before any content is written.

---

### Pitfall 2: PowerShell Profile Path Moved by OneDrive

**What goes wrong:**
`$PROFILE` on Windows resolves to `C:\Users\<user>\Documents\PowerShell\Microsoft.PowerShell_profile.ps1` by default. If OneDrive "Known Folder Move" is active, Documents redirects to `C:\Users\<user>\OneDrive\Documents\`. chezmoi stores the path it observed at `chezmoi add` time — meaning the managed path on one machine may not exist on another, causing silent non-deployment of the profile.

**Why it happens:**
Windows 10/11 ships with OneDrive enabled by default. Many machines silently redirect Documents to OneDrive during Windows setup. PowerShell's profile location is `[Environment]::GetFolderPath("MyDocuments")`, not a fixed path. chezmoi's source state stores the literal path it saw at `add` time.

**How to avoid:**
Do not use `chezmoi add $PROFILE` directly. Instead, use a chezmoi target path built from `{{ .chezmoi.homeDir }}/Documents/PowerShell/Microsoft.PowerShell_profile.ps1` and manage it as a template file, not a literal path. Alternatively, use the `CurrentUserAllHosts` profile (`profile.ps1`) which is simpler to locate. Verify `$PROFILE` path on each new Windows machine before applying.

**Warning signs:**
- `chezmoi status` on a fresh Windows machine shows the profile as "not managed"
- `$PROFILE` path contains `OneDrive` in the middle
- Profile changes applied but PowerShell does not pick them up

**Phase to address:**
Phase 2 (PowerShell profile setup). Must be the first decision: which profile path to target.

---

### Pitfall 3: SSH Agent Conflict Between Git Bash and Windows OpenSSH Service

**What goes wrong:**
Git Bash ships its own `ssh` and `ssh-agent` binaries. The Windows OpenSSH service (`ssh-agent` Windows service) is a separate implementation that does not share its key store with Git Bash's agent. If a user starts `ssh-agent` inside `.bashrc` as a standard POSIX pattern, they end up with two conflicting agents. SSH operations may work from Git Bash but fail from PowerShell or other tools, or vice versa.

**Why it happens:**
The standard POSIX `.bashrc` pattern for `ssh-agent` (`eval $(ssh-agent -s)`) spawns a fresh agent process. But `init.ps1` already configures the Windows OpenSSH service (lines 55-57). The Git Bash `ssh` binary defaults to its own bundled agent, not the Windows service socket.

**How to avoid:**
In `.bashrc`, point Git Bash at the Windows OpenSSH service instead of spawning a new agent:
```bash
export SSH_AUTH_SOCK="//./pipe/openssh-ssh-agent"
export GIT_SSH="/c/Windows/System32/OpenSSH/ssh.exe"
```
This reuses the already-running Windows service. Do NOT add a `eval $(ssh-agent)` block in the Git Bash `.bashrc` — it creates a second orphaned agent. The gitconfig already sets `core.sshCommand = C:/Windows/System32/OpenSSH/ssh.exe` on Windows; `.bashrc` must match.

**Warning signs:**
- SSH works from PowerShell but prompts for passphrase in Git Bash
- `ps aux` or Task Manager shows multiple `ssh-agent` processes
- `ssh-add -l` gives different results in different shells

**Phase to address:**
Phase 3 (Git Bash `.bashrc`). Address before any SSH-related aliases or config.

---

### Pitfall 4: Inline Environment Variable Assignment Broken in PowerShell

**What goes wrong:**
Several aliases in `40-aliases.zsh` use POSIX inline env var syntax: `LEFTHOOK=0 git push`, `LEFTHOOK=0 git rebase --continue`. This syntax is entirely invalid in PowerShell. Generating a PowerShell function that contains this pattern will silently produce a broken alias that errors at runtime.

**Why it happens:**
POSIX shells evaluate `VAR=value command` as a temporary environment mutation for that command. PowerShell has no equivalent syntax. The closest PowerShell equivalent requires `$env:LEFTHOOK = 0; git ...; Remove-Item Env:LEFTHOOK` or wrapping in a try/finally block.

**How to avoid:**
When generating PowerShell functions from shared alias definitions, all inline env-var prefixes must be rewritten as explicit `$env:` assignments. Use a wrapper pattern:
```powershell
function gpf {
    $env:LEFTHOOK = "0"
    git push origin HEAD --force-with-lease
    Remove-Item Env:LEFTHOOK -ErrorAction SilentlyContinue
}
```
The chezmoi template generating PowerShell functions must handle this transformation explicitly.

**Warning signs:**
- Template-generated PowerShell function file contains lines like `LEFTHOOK=0 git ...`
- Running the alias produces `LEFTHOOK=0 : The term 'LEFTHOOK=0' is not recognized...`

**Phase to address:**
Phase 1 (shared alias template design). Decide on the translation rules before writing templates.

---

### Pitfall 5: Multiline Alias Bodies Break PowerShell Functions

**What goes wrong:**
The `yta` alias in `40-aliases.zsh` spans multiple lines using backslash continuation. The `docker-clean` alias uses `\` + newline for continuation. When these are naively included in a chezmoi template and rendered as PowerShell functions, the backslashes become PowerShell escape characters (backtick is PowerShell's escape character, not backslash), producing syntax errors or mangled commands.

**Why it happens:**
In bash/zsh, `\` at end-of-line is a line continuation. In PowerShell, `\` is a literal path separator or string character. PowerShell uses `` ` `` (backtick) for line continuation, but even that is fragile — any trailing space after the backtick breaks the continuation silently.

**How to avoid:**
Store long alias bodies as single-line strings in the shared template data, or use PowerShell's natural multi-line capability inside function bodies (no continuation character needed between arguments on separate lines inside `{}`). Do not attempt to port the backslash continuation style directly.

**Warning signs:**
- Generated PowerShell profile contains `\` at end of lines outside of path strings
- `yta` or `docker-clean` function throws parse errors when the profile loads

**Phase to address:**
Phase 1 (template design). Normalize alias body representation before writing the template engine.

---

### Pitfall 6: `Set-Alias` Cannot Hold Arguments — Needs Function Wrappers for Everything

**What goes wrong:**
`Set-Alias ls eza -lh` is invalid PowerShell. `Set-Alias` maps a name to a command name only — no flags, no arguments. Any alias from `40-aliases.zsh` that calls a command with flags (virtually all of them) cannot be expressed as `Set-Alias`.

**Why it happens:**
PowerShell's alias system is intentionally minimal — aliases are pure name remapping. All behavior customization is done via functions. This is the correct PowerShell idiom but requires generating `function` blocks instead of `Set-Alias` calls for the vast majority of shared aliases.

**How to avoid:**
The chezmoi template must always generate `function <name> { <command> @args }` for aliases that include flags or complex logic. `Set-Alias` is only appropriate for pure command renames (e.g., `Set-Alias vi vim`). For aliases that pass through additional user arguments, use `@args` splatting in the function body.

**Warning signs:**
- Generated profile contains `Set-Alias ls eza` (with arguments) — will error at load time
- Profile loads silently but `ls` and `ll` do not work as expected

**Phase to address:**
Phase 2 (PowerShell profile). Establish the function-generation convention from the start.

---

### Pitfall 7: CRLF Line Endings in chezmoi-Generated Files on Windows

**What goes wrong:**
chezmoi template functions use Unix-style line endings (LF) internally. Without explicit line-ending directives, template output on Windows may have inconsistent endings — LF in the generated file but CRLF expected by some Windows tools. More critically, if the chezmoi source template file itself is saved with CRLF (e.g., by a Windows editor), `chezmoi diff` perpetually shows "changes" even when there are none.

**Why it happens:**
Go's template engine produces LF output. Git on Windows (with `core.autocrlf = input` as set in `.gitconfig.tmpl`) normalizes line endings at checkout, but template-generated target files bypass Git and go directly to disk.

**How to avoid:**
Add a chezmoi line-ending directive at the top of any template generating files for Windows consumption:
```
{{- /* chezmoi:template:line-endings lf */ -}}
```
Keep all source `.tmpl` files in LF (`.gitattributes` already handles this for tracked files via `core.autocrlf = input`). For PowerShell profiles specifically, LF is safe with PowerShell 7+ and PS 5.1 with UTF-8 without BOM.

**Warning signs:**
- `chezmoi diff` always shows the PowerShell profile as changed despite no real edits
- PowerShell profile loads but produces garbled output for non-ASCII content

**Phase to address:**
Phase 2 (PowerShell profile). Add the directive before first apply on Windows.

---

### Pitfall 8: PowerShell File Encoding — UTF-8 BOM Required for Windows PowerShell 5.1

**What goes wrong:**
The chezmoi-generated PowerShell profile contains non-ASCII characters (e.g., in `EZA_COLORS`, starship prompts, or comments). Windows PowerShell 5.1 defaults to ANSI codepage when reading UTF-8 files without BOM, corrupting non-ASCII content. PowerShell 7+ defaults to UTF-8 without BOM and handles it correctly. If the file contains only ASCII, no problem appears — until it doesn't.

**Why it happens:**
chezmoi writes files as UTF-8 without BOM by default. PowerShell 5.1 (which ships with Windows) misreads UTF-8 without BOM as ANSI. PowerShell 7+ correctly reads UTF-8 without BOM.

**How to avoid:**
Since `init.ps1` installs PowerShell 7 via winget, the target is PowerShell 7+, and UTF-8 without BOM is correct. However, add a comment in the template noting this assumption. If Windows PowerShell 5.1 compatibility is ever needed, the template must be adjusted to produce BOM-prefixed output.

**Warning signs:**
- Non-ASCII characters (in env var values, comments, etc.) display as `â€˜` or similar garbage
- Profile loads but encoded strings are wrong

**Phase to address:**
Phase 2 (PowerShell profile). Note the encoding assumption explicitly.

---

## Technical Debt Patterns

| Shortcut | Immediate Benefit | Long-term Cost | When Acceptable |
|----------|-------------------|----------------|-----------------|
| Hardcode `LEFTHOOK=0` in bash-syntax inside template | Faster initial implementation | PowerShell functions break silently; must retrofit all aliases | Never — translate inline env vars from the start |
| Use `Set-Alias` for all aliases in PowerShell | Simple template logic | All flag-bearing aliases fail at profile load | Only acceptable for pure command-rename aliases (vi=vim) |
| Skip `.chezmoiignore` OS guards for new shell files | Simpler file structure | chezmoi tries to deploy `.bashrc` on Linux or PowerShell profile on Linux | Never — OS guards are required from day one |
| Spawn `ssh-agent` in `.bashrc` (POSIX style) | Familiar pattern | Conflicts with Windows OpenSSH service already managed by `init.ps1` | Never on Windows |
| Use `{{ template "..." }}` without the trailing dot | Works if no `.chezmoi.*` vars in sub-template | Any future use of OS detection in shared templates silently fails | Only if sub-template is guaranteed 100% static content forever |
| Target `$PROFILE` path directly in chezmoi | Simple setup | Non-portable across OneDrive-redirected machines | Never — use computed path from `.chezmoi.homeDir` |

## Integration Gotchas

| Integration | Common Mistake | Correct Approach |
|-------------|----------------|------------------|
| ejson decryption on Windows | Shell script (`run_*.sh`) used to invoke ejson decrypt — fails with "not a valid Win32 application" | Use chezmoi's built-in `ejsonDecrypt` template function; avoid `run_` shell scripts for decryption on Windows |
| mise in PowerShell | Using `Invoke-Expression (mise activate powershell)` (old syntax) vs. `(&mise activate pwsh) \| Out-String \| Invoke-Expression` | Use the `pwsh` target, not `powershell`; the `init.ps1` currently uses the old form — verify against current mise docs |
| mise in Git Bash | Adding shims to PATH manually (inconsistent with activate model) | Use `eval "$(mise activate bash)"` — consistent with the existing `dot_bashrc` pattern |
| Windows OpenSSH + Git Bash SSH | Git Bash uses its own ssh binary ignoring Windows agent | Set `SSH_AUTH_SOCK` and `GIT_SSH` in `.bashrc` to point at Windows service |
| chezmoi ejson key location | `ejsonDecrypt` looks for key in `$EJSON_KEYDIR` (default `/opt/ejson/keys` on Linux, undefined on Windows) | Ensure `EJSON_KEYDIR` or equivalent is set before `chezmoi apply` on Windows; verify key discovery path |

## Performance Traps

| Trap | Symptoms | Prevention | When It Breaks |
|------|----------|------------|----------------|
| `mise activate` adds hook that runs on every prompt | Noticeable shell startup lag | This is expected and acceptable; do not switch to shims-only for interactive shells | Becomes noticeable with complex `mise.toml` or large tool sets |
| `lookPath` in chezmoi templates for tool detection | Template result changes between machines depending on what is installed | Use `lookPath` only for optional feature gates; never as a hard dependency; document expected behavior | Any machine where tools are not installed yet |
| Git Bash slow startup due to network probe | Git Bash takes 5-30 seconds to open | Avoid network calls during `.bashrc` execution; check `MSYS_NO_PATHCONV` env | Any machine with certain network/DNS configurations |

## Security Mistakes

| Mistake | Risk | Prevention |
|---------|------|------------|
| Committing `GEMINI_API_KEY` in plaintext to a shared template | API key leaks to anyone with repo access | Continue using ejson; the `ejsonDecrypt` call in `20-exports.zsh.tmpl` is the correct pattern — replicate for PowerShell profile |
| Placing ejson private key in a location tracked by chezmoi | Private key committed to dotfiles repo | Keep private key only in `$EJSON_KEYDIR`; it must never appear in chezmoi source state |
| PowerShell `ExecutionPolicy Unrestricted` | Any script runs without warning | Use `RemoteSigned` (as `init.ps1` already does) — never `Unrestricted` |
| Putting API keys in `.bashrc` plaintext as fallback when ejson unavailable | Key leaks in shell history and config files | If ejson is unavailable on Windows, fail loudly rather than falling back to plaintext; the PROJECT.md explicitly notes "no fallback needed" |

## UX Pitfalls

| Pitfall | User Impact | Better Approach |
|---------|-------------|-----------------|
| PowerShell profile silently not loaded due to wrong path | Aliases and mise not available; user debugging is confusing | Print a test line from the profile or verify on first apply; add `chezmoi doctor`-style verification step |
| Git Bash `.bashrc` applied but contains Linux-only aliases | Aliases like `yay`, `brewfile` error in Git Bash | Enforce the Linux-only exclusion list from `PROJECT.md` in the shared template from day one |
| `czapply` alias in PowerShell tries to `source "$HOME/.zshrc"` | `.zshrc` does not exist on Windows; cryptic error after every apply | The `czapply` alias must have an OS-conditional body in the shared template — Windows version omits the source step |

## "Looks Done But Isn't" Checklist

- [ ] **Shared template invocations:** Verify every `{{ template "..." }}` call includes trailing `.` — check with `chezmoi execute-template` on a template that uses `.chezmoi.os`
- [ ] **PowerShell profile path:** Confirm `$PROFILE` resolves to the chezmoi-managed path on the target Windows machine — check for OneDrive redirect
- [ ] **SSH agent:** Confirm `ssh-add -l` returns the same keys in both PowerShell and Git Bash — one agent, not two
- [ ] **Inline env vars:** Search generated PowerShell profile for `LEFTHOOK=0` or any `KEY=value command` patterns — should be zero
- [ ] **mise activation syntax:** Confirm `(&mise activate pwsh) | Out-String | Invoke-Expression` is used (not the old `Invoke-Expression (mise activate powershell)`)
- [ ] **Line endings:** Run `file ~/.config/powershell/Microsoft.PowerShell_profile.ps1` — should show `ASCII` or `UTF-8 Unicode text` not `CRLF`
- [ ] **ejson on Windows:** Confirm `EJSON_KEYDIR` is set and `chezmoi apply` does not error on the API key template line before the PowerShell profile can be used
- [ ] **Linux-only aliases excluded:** Confirm `yay`, `brewfile`, `bundleantidote`, `updatedesktopdb` are absent from generated PowerShell and Git Bash files
- [ ] **`.chezmoiignore` guards:** Confirm PowerShell profile is not deployed on Linux; Git Bash `.bashrc` is not deployed on Linux

## Recovery Strategies

| Pitfall | Recovery Cost | Recovery Steps |
|---------|---------------|----------------|
| Nil data in sub-templates | LOW | Add `. ` to all `{{ template "..." }}` calls; `chezmoi apply -v` to redeploy |
| Wrong PowerShell profile path (OneDrive) | MEDIUM | `chezmoi forget` old path; re-add with correct computed path; re-apply |
| Dual ssh-agent conflict | LOW | Remove `eval $(ssh-agent)` from `.bashrc`; add `SSH_AUTH_SOCK` redirect; restart terminal |
| PowerShell profile fails to load (broken functions) | LOW | `chezmoi apply --dry-run` to preview; fix template; `chezmoi apply` |
| CRLF causing perpetual diff | LOW | Add `chezmoi:template:line-endings lf` directive; `chezmoi apply` |

## Pitfall-to-Phase Mapping

| Pitfall | Prevention Phase | Verification |
|---------|------------------|--------------|
| Sub-template nil data | Phase 1: Shared template structure | `chezmoi execute-template '{{ template "shared.tmpl" . }}'` includes `.chezmoi.os` |
| OneDrive PowerShell profile path | Phase 2: PowerShell profile | `$PROFILE` path matches chezmoi managed path on test machine |
| SSH agent conflict | Phase 3: Git Bash `.bashrc` | `ssh-add -l` identical output in both shells |
| Inline env var syntax (LEFTHOOK) | Phase 1: Template design | Generated profile contains zero `VAR=val cmd` patterns |
| Multiline alias backslash | Phase 1: Template design | Generated profile parses without errors (`pwsh -NonInteractive -Command `. $PROFILE``) |
| Set-Alias with arguments | Phase 2: PowerShell profile | All flag-bearing commands use `function` blocks |
| CRLF line endings | Phase 2: PowerShell profile | `chezmoi diff` shows no changes after clean apply |
| UTF-8 BOM encoding | Phase 2: PowerShell profile | Profile loads cleanly in PS 7+ with non-ASCII content |
| ejson unavailable on Windows | Phase 2: PowerShell profile | `chezmoi apply` succeeds on Windows with API key present |
| Linux-only aliases in Windows shells | Phase 1: Template design | Alias exclusion list matches `PROJECT.md` spec |

## Sources

- [chezmoi Windows user guide](https://www.chezmoi.io/user-guide/machines/windows/)
- [chezmoi templating documentation](https://www.chezmoi.io/user-guide/templating/)
- [chezmoi `.chezmoiignore` reference](https://www.chezmoi.io/reference/special-files/chezmoiignore/)
- [chezmoi machine differences guide](https://www.chezmoi.io/user-guide/manage-machine-to-machine-differences/)
- [chezmoi `ejsonDecrypt` reference](https://www.chezmoi.io/reference/templates/ejson-functions/ejsonDecrypt/)
- [GitHub Issue #2125 — `.chezmoitemplates` nil data (Windows cross-platform)](https://github.com/twpayne/chezmoi/issues/2125)
- [GitHub Issue #2138 — OneDrive non-portable paths in chezmoi](https://github.com/twpayne/chezmoi/issues/2138)
- [mise Getting Started docs — PowerShell activation](https://mise.jdx.dev/getting-started.html)
- [mise Discussion #8090 — shims vs activate inconsistency for PowerShell](https://github.com/jdx/mise/discussions/8090)
- [PowerShell about_Aliases (PS 7.5)](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_aliases?view=powershell-7.5)
- [PowerShell about_Character_Encoding](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_character_encoding?view=powershell-7.4)
- [PowerShell profile load order — PDQ](https://www.pdq.com/blog/powershell-profile-load-order/)
- [Git for Windows SSH conflict — git-for-windows/git Issue #2944](https://github.com/git-for-windows/git/issues/2944)
- [SSH agent setup for Git Bash / MinGW / Windows — GitHub Gist](https://gist.github.com/JanTvrdik/33df5554d981973fce02)
- [Git Bash path conversion — CloudBees KB](https://support.cloudbees.com/hc/en-us/articles/360033184131-KBEC-00420-Stopping-Path-Conversion-for-Git-Bash)
- [PowerShell Set-Alias limitation — GitHub Issue #11310](https://github.com/PowerShell/PowerShell/issues/11310)
- [mintty Tips wiki](https://github.com/mintty/mintty/wiki/Tips)

---
*Pitfalls research for: Cross-shell dotfiles configuration (chezmoi + PowerShell + Git Bash)*
*Researched: 2026-03-14*