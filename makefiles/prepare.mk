.PHONY: prepare ci-sudo brew git zsh version-managers
prepare: ci-sudo brew git zsh version-managers

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

zsh: ZSH_BIN=$(HOMEBREW_PREFIX)/bin/zsh
zsh: BREW_BIN=$(HOMEBREW_PREFIX)/bin/brew
zsh: SHELLS=/private/etc/shells
zsh:
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
