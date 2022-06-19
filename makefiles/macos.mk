.PHONY: macos ci-sudo brew git stow
macos: ci-sudo brew git stow

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
