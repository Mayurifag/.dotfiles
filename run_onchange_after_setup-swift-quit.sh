#!/bin/sh
# Swift Quit preferences
# Edit this file to update settings — chezmoi apply will re-run on change

set -eu

defaults write onebadidea.Swift-Quit "NSStatusItem Visible Item-0" -bool false
defaults write onebadidea.Swift-Quit "launchAtLogin.isEnabled" -int 1

defaults write onebadidea.Swift-Quit SwiftQuitSettings -dict \
  excludeBehaviour excludeApps \
  launchAtLogin true \
  menubarIconEnabled false

defaults write onebadidea.Swift-Quit SwiftQuitExcludedApps -array \
  "/Applications/Raycast.app" \
  "/Applications/Karabiner-Elements.app" \
  "/Applications/qBittorrent.app" \
  "/Applications/iTerm.app" \
  "/Applications/AyuGram.app" \
  "/Applications/OrbStack.app" \
  "/Applications/OpenCloud.app" \
  "/Applications/Transmission.app" \
  "/Applications/AltTab.app" \
  "/Applications/Espanso.app" \
  "/Applications/LocalSend.app" \
  "/Applications/MEGAsync.app" \
  "/Applications/KeePassXC.app" \
  "/Applications/TickTick.app" \
  "/Applications/CodexBar.app" \
  "/Users/mayurifag/Applications/chromium-profile-syncer.app"

# Restart Swift Quit so it picks up the updated excluded-apps list
# (the running instance caches the list at launch)
killall "Swift Quit" 2>/dev/null || true
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "/Applications/Swift Quit.app"
open -a "Swift Quit"
