.PHONY: mise-packages
mise-packages: mise-install node-packages rust-packages ruby-packages go-packages

.PHONY: node-packages
node-packages:
	npm install -g $(shell cat install/npmfile)

.PHONY: rust-packages
rust-packages:
	cargo install $(shell cat install/Rustfile)

.PHONY: ruby-packages
ruby-packages:
	gem install $(shell cat install/Rubyfile)

.PHONY: go-packages
go-packages:
	cat install/Gofile | xargs -I {} go install {}@latest

.PHONY: mise-install
mise-install:
	mise install

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
################################################
