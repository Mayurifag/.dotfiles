.PHONY: prepare ci-sudo brew git stow zsh version-managers link
prepare: ci-sudo brew git stow zsh link version-managers

DOTFILES_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
export XDG_CONFIG_HOME = $(HOME)/.config
export STOW_DIR = $(DOTFILES_DIR)

ci-sudo:
ifndef GITHUB_ACTION
	sudo -v
	while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
endif

brew:
	curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh | bash

git:
	brew install git git-extras
	mkdir -p $(HOME)/Code
	mkdir -p $(HOME)/Work

stow:
	brew install stow

zsh: ZSH_BIN=$(HOMEBREW_PREFIX)/bin/zsh
zsh: BREW_BIN=$(HOMEBREW_PREFIX)/bin/brew
zsh: SHELLS=/private/etc/shells
zsh: brew
ifdef GITHUB_ACTION
	if ! grep -q $(ZSH_BIN) $(SHELLS); then \
		$(BREW_BIN) install zsh && \
		sudo append $(ZSH_BIN) $(SHELLS) && \
		sudo chsh -s $(ZSH_BIN); \
	fi
else
	if ! grep -q $(ZSH_BIN) $(SHELLS); then \
		$(BREW_BIN) install zsh && \
		sudo append $(ZSH_BIN) $(SHELLS) && \
		chsh -s $(ZSH_BIN); \
	fi
endif

version-managers:
	brew install fnm
	brew install frum
	eval "$(frum init)"
	eval "$(fnm env --use-on-cd)"

link:
# for FILE in $$(\ls -A stowfiles); do if [ -f $(HOME)/$$FILE -a ! -h $(HOME)/$$FILE ]; then \
# 	mv -v $(HOME)/$$FILE{,.bak}; fi; done
	mkdir -p $(XDG_CONFIG_HOME)
	stow -t $(HOME) stowfiles
	stow -t $(XDG_CONFIG_HOME) config

unlink:
	stow --delete -t $(HOME) stowfiles
	stow --delete -t $(XDG_CONFIG_HOME) config
# for FILE in $$(\ls -A stowfiles); do if [ -f $(HOME)/$$FILE.bak ]; then \
# 	mv -v $(HOME)/$$FILE.bak $(HOME)/$${FILE%%.bak}; fi; done
