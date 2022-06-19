.PHONY: macos ci-sudo brew git stow dock macos-settings fzf
macos: ci-sudo brew git stow dock macos-settings fzf

ci-sudo:
ifndef GITHUB_ACTION
	sudo -v
	while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
endif

brew:
	curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh | bash

git: brew
	brew install git git-extras
	mkdir -p $(HOME)/Code
	mkdir -p $(HOME)/Work

stow: brew
	brew install stow

dock:
	brew list dockutil &>/dev/null || brew install dockutil
	. ./macos/dock.sh

macos-settings:
	. ./macos/defaults.sh
