# Steam Deck / SteamOS

- Treat the SteamOS system image as immutable. Do not disable read-only protection, modify vendor system files, or use
  pacman/AUR to install apps. Updates replace those changes.
- Prefer official AppImages, Flatpak, or other home-local installs that survive SteamOS updates. Do not default to mise
  for GUI apps; choose the simplest suitable supported format.
- Make `/etc` changes only for explicitly requested system integration. Keep them minimal, manage deployment in chezmoi,
  and verify Valve's update-preservation rules. Never preserve all of `/etc`.
