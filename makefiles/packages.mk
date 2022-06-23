.PHONY: packages brew-packages node-packages rust-packages code-settings ruby-packages fzf antibody
packages: brew-packages node-packages rust-packages code-settings ruby-packages fzf

brew-packages:
	brew bundle --file=$(DOTFILES_DIR)/install/Brewfile || true

code-settings:
	for EXT in $$(cat install/Codefile); do code --install-extension $$EXT; done

node-packages:
	npm install -g $(shell cat install/npmfile)

rust-packages:
	cargo install $(shell cat install/Rustfile)

ruby-packages:
	gem install $(shell cat install/Rubyfile)

fzf:
	brew install fzf
	/opt/homebrew/opt/fzf/install

# TODO
antibody:
	brew install antibody
	antibody bundle < $(DOTFILES_DIR)/stowfiles/zsh/plugins.txt > $(HOME)/.zsh_plugins.sh
