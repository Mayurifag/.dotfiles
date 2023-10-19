.PHONY: packages brew-packages node-packages rust-packages ruby-packages fzf antidote
packages: brew-packages node-packages rust-packages ruby-packages fzf

brew-packages:
	brew bundle --file=$(DOTFILES_DIR)/install/Brewfile || true

node-packages:
	npm install -g $(shell cat install/npmfile)

rust-packages:
	cargo install $(shell cat install/Rustfile)

ruby-packages:
	gem install $(shell cat install/Rubyfile)

fzf:
	brew install fzf
	/opt/homebrew/opt/fzf/install

antidote:
	brew install antidote
	antidote bundle < $(DOTFILES_DIR)/zsh/plugins.txt > $(HOME)/.zsh_plugins.sh
