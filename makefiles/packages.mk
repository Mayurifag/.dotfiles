.PHONY: packages brew-packages node-packages rust-packages ruby-packages antidote
packages: node-packages rust-packages ruby-packages

brew-packages:
	brew bundle --file=$(DOTFILES_DIR)/install/Brewfile || true

node-packages:
	npm install -g $(shell cat install/npmfile)

rust-packages:
	cargo install $(shell cat install/Rustfile)

ruby-packages:
	gem install $(shell cat install/Rubyfile)

antidote:
	brew install antidote
	antidote bundle < $(DOTFILES_DIR)/zsh/plugins.txt > $(HOME)/zsh/.zsh_plugins.sh
