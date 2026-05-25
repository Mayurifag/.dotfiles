PACKAGE_SCRIPT := $(DOTFILES_DIR)/makefiles/packages.sh
PACKAGE := sh "$(PACKAGE_SCRIPT)"
MISE_PACKAGE := mise exec -- $(PACKAGE)

.PHONY: mise-sync clean-mise-installs mise-packages mise-install
.PHONY: node-packages rust-packages ruby-packages go-packages uv-packages
.PHONY: clean-node-packages clean-rust-packages clean-ruby-packages clean-go-packages clean-uv-packages

mise-sync:
	$(PACKAGE) mise-sync

clean-mise-installs:
	$(PACKAGE) clean-mise-installs

mise-packages:
	$(PACKAGE) mise-packages

mise-install:
	$(PACKAGE) mise-install

node-packages:
	$(MISE_PACKAGE) node-packages

rust-packages:
	$(MISE_PACKAGE) rust-packages

ruby-packages:
	$(MISE_PACKAGE) ruby-packages

go-packages:
	$(MISE_PACKAGE) go-packages

uv-packages:
	$(MISE_PACKAGE) uv-packages

clean-node-packages:
	$(MISE_PACKAGE) clean-node-packages

clean-rust-packages:
	$(MISE_PACKAGE) clean-rust-packages

clean-ruby-packages:
	$(MISE_PACKAGE) clean-ruby-packages

clean-go-packages:
	$(MISE_PACKAGE) clean-go-packages

clean-uv-packages:
	$(MISE_PACKAGE) clean-uv-packages

################################################
# Thats better to fully upgrade first before using those package managers

.PHONY: brew-packages
brew-packages:
	brew bundle --file=$(DOTFILES_DIR)/install/Brewfile || true

.PHONY: arch-packages
arch-packages:
	if command -v yay >/dev/null 2>&1; then \
			yay -S --needed --noconfirm $(shell cat install/Archfile); \
	fi

.PHONY: winget-packages
winget-packages:
	$(PACKAGE) winget-packages
################################################
