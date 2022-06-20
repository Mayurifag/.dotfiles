PHONY: macos-system-settings dock macos-settings
macos-system-settings: dock macos-settings

dock:
	brew install --cask hpedrorodrigues/tools/dockutil
	. ./macos/dock.sh

macos-settings:
	. ./macos/defaults.sh
