PHONY: macos-system-settings dock macos-settings
macos-system-settings: dock macos-settings

dock:
	brew list dockutil &>/dev/null || brew install dockutil
	. ./macos/dock.sh

macos-settings:
	. ./macos/defaults.sh
