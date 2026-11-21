# Package Ownership

- `install/*file` (`npmfile`, `Brewfile`, `Wingetfile`, `uv-file`, `Gofile`, etc.) is authoritative;
  `make mise-packages` should prune unlisted globals.
- Package ownership and manager migrations -> `~/airules/installation.md`.
- Before permanent installs, update the matching manifest, even if upstream prescribes global installs.
- Temporary tools or Steam Deck AppImage/Flatpak installs -> `~/airules/installation.md`; do not create unused Steam
  Deck package manifests.
- Winget -> add ID to `install/Wingetfile`, then `make winget-packages`. Hand-run `winget install` only if that target
  is unavailable or being debugged, with
  `--silent --disable-interactivity --accept-package-agreements --accept-source-agreements`.
- Windows MinGW ->
  `winget install --id BrechtSanders.WinLibs.POSIX.UCRT --exact --silent --disable-interactivity --accept-package-agreements --accept-source-agreements`,
  not MSYS2 `pacman`.
