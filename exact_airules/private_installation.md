# Installation and Deployment

- On this Mac, disabled Gatekeeper assessments and the CleanShot X build without an Apple Developer ID are intentional.
  Do not flag either by itself in routine audits or change either unless asked. Report separate evidence of compromise.
- Do not update CleanShot X via a package manager or its app updater unless the user explicitly asks to update it.
- Prefer isolated temporary tools and clean up task-owned artifacts. Treat explicit requests as approval for routine
  downloads, installs, upgrades, and privileged commands; do not ask again. Ask before destructive, irreversible, or
  otherwise high-impact actions, and state the specific risk.
- Check readily available official docs/source for optional telemetry and crash reporting, proportionate to the app and
  risk. Disable reporting through straightforward supported settings when functionality is preserved; persist and verify
  opt-outs when practical.
- Do not delay routine upgrades for uncertain telemetry or unavailable opt-outs. Preserve security/update traffic and
  useful logs; explain and ask before invasive patches or network blocking. Report known collection and material gaps.

## Package Ownership

- Before OS dependencies, check ignored packages and mise runtimes. Never override `IgnorePkg` without approval or
  duplicate a mise-owned runtime.
- Give each package one owner. Prefer cross-platform tool/language managers; use OS managers for OS-specific apps,
  system libraries, GUI apps, drivers, fonts, or unsuitable/unavailable tools.
- Full-machine upgrades -> update pinned tools and packages to compatible stable versions in their authoritative
  manifests, then install and verify. Remove superseded versions, stale installer caches, and duplicate ownership when
  safe; retain and report versions required by active work or incompatible projects.
- Before pruning runtimes, check active processes, project pins, and virtualenv interpreter paths; manager prune
  previews may miss virtualenvs.
- When moving/removing packages, update the old manager file and uninstall/prune from the current machine.
- This machine's managed package lists and install commands -> `~/airules/chezmoi.md`.

## Task References

- Steam Deck / SteamOS installs or system integration -> `~/airules/installation/steamos.md`
