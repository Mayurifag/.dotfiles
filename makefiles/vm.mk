NODE_VERSION="18.4.0"
RUBY_VERSION="3.1.2"

.PHONY: vm
vm: fnm frum

fnm:
	fnm install $(NODE_VERSION)
	fnm use $(NODE_VERSION)

frum:
	frum install $(RUBY_VERSION)
