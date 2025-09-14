.PHONY: mise-packages
mise-packages: mise-install node-packages rust-packages ruby-packages go-packages uv-packages stew-packages

.PHONY: node-packages
node-packages:
	npm install -g $(shell cat install/npmfile)

.PHONY: rust-packages
rust-packages:
	cargo install $(shell cat install/Rustfile)

.PHONY: ruby-packages
ruby-packages:
	gem update --system
	gem install $(shell cat install/Rubyfile)

.PHONY: go-packages
go-packages:
	cat install/Gofile | xargs -I {} go install {}@latest

.PHONY: uv-packages
uv-packages:
	cat install/uv-file | xargs -I {} uv tool install {}

.PHONY: mise-install
mise-install:
	mise install

.PHONY: stew-packages
stew-packages:
	@while IFS= read -r package <&3; do \
		if [ -n "$$package" ] && [ "$${package#\#}" = "$$package" ]; then \
			if [ -f ~/.local/share/stew/Stewfile.lock.json ]; then \
				owner_repo="$$package"; \
				owner=$$(echo "$$owner_repo" | cut -d'/' -f1); \
				repo=$$(echo "$$owner_repo" | cut -d'/' -f2); \
				if jq -e --arg owner "$$owner" --arg repo "$$repo" '.packages[] | select(.owner == $$owner and .repo == $$repo)' ~/.local/share/stew/Stewfile.lock.json >/dev/null 2>&1; then \
					echo "Package $$package already installed, skipping..."; \
				else \
					echo "Package $$package not found in lock file, installing..."; \
					stew install "$$package" </dev/tty || exit 1; \
				fi; \
			else \
				echo "No lock file found, installing $$package..."; \
				stew install "$$package" </dev/tty || exit 1; \
			fi; \
		fi; \
	done 3< install/Stewfile
	stew upgrade --all

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
