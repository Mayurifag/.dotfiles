#!/bin/sh

dockutil --no-restart --remove all

dockutil --no-restart --add "/Applications/Launchpad.app"
# dockutil --no-restart --add "/Applications/Firefox.app"
# dockutil --no-restart --add "/Applications/KeepassXC.app"
dockutil --no-restart --add "/System/Applications/System Preferences.app"
dockutil --no-restart --add "/Applications/Gitkraken.app"
dockutil --no-restart --add "/Applications/Steam.app"
dockutil --no-restart --add "/Applications/Visual Studio Code.app"
dockutil --no-restart --add "/Applications/Streamlink Twitch GUI.app"
dockutil --no-restart --add "/Applications/Telegram.app"
dockutil --no-restart --add "/Applications/Discord.app"
dockutil --no-restart --add "/Applications/TickTick.app"
# dockutil --no-restart --add "/System/Applications/Mail.app"
dockutil --no-restart --add "/Applications/Mattermost.app"
dockutil --no-restart --add "/Applications/qBittorrent.app"

killall Dock
