.PHONY: packages brew-packages node-packages rust-packages code-settings ruby-packages fzf
packages: brew-packages node-packages rust-packages code-settings ruby-packages fzf

brew-packages: brew
	brew bundle --file=$(DOTFILES_DIR)/install/Brewfile || true

code-settings:
	for EXT in $$(cat install/Codefile); do code --install-extension $$EXT; done

node-packages:
	eval "$(fnm env)"; npm install -g $(shell cat install/npmfile)

rust-packages:
	cargo install $(shell cat install/Rustfile)

ruby-packages:
	eval "$(frum init)"; gem install $(shell cat install/Rubyfile)

fzf:
	brew install fzf
	$(brew --prefix)/opt/fzf/install
