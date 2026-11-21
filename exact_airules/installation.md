# Installation and Deployment

- Do not update CleanShot X via a package manager or its app updater unless the user explicitly asks to update it.
- Prefer isolated temporary tools and clean up task-owned artifacts. Treat explicit requests as approval for routine
  downloads, installs, upgrades, and privileged commands; do not ask again. Ask before destructive, irreversible, or
  otherwise high-impact actions, and state the specific risk.
- Before installs/deployments/upgrades, research telemetry, analytics, usage/crash reporting, diagnostics, and metrics
  in official docs/source for the selected version; self-hosted/open-source does not imply telemetry-free.
- Disable optional vendor reporting/unnecessary collection through supported settings, preferably before first start; no
  approval needed if functionality is preserved. Cover installers, services, clients, and bundled components.
- Persist opt-outs in authoritative config/deployment source. Verify exact flags, env vars, config keys, defaults, and
  coverage; never invent settings.
- Preserve necessary traffic, security/update checks, operational logs, useful local metrics, and requested monitoring.
  Explain and ask before opt-outs that break functionality or require invasive patches/network blocking.
- Verify effective settings when practical; configured opt-outs do not prove network silence. In the final response,
  report collection found, opt-outs and locations, unsupported opt-outs, unavoidable/enabled collection, and uncertainty
  or verification gaps. If none was found, name sources checked rather than asserting absence.

## Package Ownership

- Before OS dependencies, check ignored packages and mise runtimes. Never override `IgnorePkg` without approval or
  duplicate a mise-owned runtime.
- Give each package one owner. Prefer cross-platform tool/language managers; use OS managers for OS-specific apps,
  system libraries, GUI apps, drivers, fonts, or unsuitable/unavailable tools.
- When moving/removing packages, update the old manager file and uninstall/prune from the current machine.
- This machine's managed package lists and install commands -> `~/airules/chezmoi.md`.

## Task References

- Steam Deck / SteamOS installs or system integration -> `~/airules/installation/steamos.md`
