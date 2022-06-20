export XDG_CONFIG_HOME = $(HOME)/.config
export STOW_DIR = $(DOTFILES_DIR)

.PHONY: link
# link:
# 	for FILE in $$(\ls -A stowfiles); do if [ -f $(HOME)/$$FILE -a ! -h $(HOME)/$$FILE ]; then \
# 		mv -v $(HOME)/$$FILE{,.bak}; fi; done
# 	mkdir -p $(XDG_CONFIG_HOME)
# 	stow -t $(HOME) stowfiles
# 	stow -t $(XDG_CONFIG_HOME) config

# unlink:
# 	stow --delete -t $(HOME) stowfiles
# 	stow --delete -t $(XDG_CONFIG_HOME) config
# 	for FILE in $$(\ls -A stowfiles); do if [ -f $(HOME)/$$FILE.bak ]; then \
# 		mv -v $(HOME)/$$FILE.bak $(HOME)/$${FILE%%.bak}; fi; done
