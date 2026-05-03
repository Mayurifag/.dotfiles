.PHONY: mise-packages
mise-packages: mise-install node-packages rust-packages ruby-packages go-packages uv-packages

.PHONY: node-packages
node-packages:
	npm install -g $(shell cat install/npmfile)
	mise reshim

.PHONY: rust-packages
rust-packages:
	cargo install --force $(shell cat install/Rustfile)
	mise reshim

.PHONY: ruby-packages
ruby-packages:
	gem update --system
	gem install $(shell cat install/Rubyfile)
	mise reshim

.PHONY: go-packages
go-packages:
	cat install/Gofile | xargs -I {} go install {}@latest
	mise reshim

.PHONY: uv-packages
uv-packages:
	cat install/uv-file | xargs -I {} uv tool install {}
	mise reshim

.PHONY: mise-install
mise-install:
	mise install
	mise upgrade
	mise reshim

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
