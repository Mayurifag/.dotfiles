# ASDF=${HOME}/.asdf/bin/asdf
NODE_VERSION="18.4.0"
RUBY_VERSION="3.1.2"

.PHONY: vm
# vm:
# 	rm -rf ${HOME}/.asdf
# 	git clone https://github.com/asdf-vm/asdf.git $(HOME)/.asdf --branch v0.10.0
# 	. $(HOME)/.asdf/asdf.sh
# 	source $(HOME)/zsh/exports.zsh
# 	${ASDF} plugin-add ruby https://github.com/asdf-vm/asdf-ruby.git
# 	${ASDF} plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git
# 	${ASDF} plugin-add yarn https://github.com/twuni/asdf-yarn.git
# 	${ASDF} reshim
# 	${ASDF} install nodejs $(NODE_VERSION)
# 	${ASDF} global nodejs $(NODE_VERSION)
# 	${ASDF} install ruby latest
# 	${ASDF} global ruby latest
# 	${ASDF} install yarn latest
# 	${ASDF} global yarn latest

vm: fnm frum

fnm:
	fnm install --lts
	eval "$(fnm env)"; npm install -g yarn

frum:
	brew install frum
	eval "$(frum init)"; frum install --with-jemalloc $(RUBY_VERSION)
