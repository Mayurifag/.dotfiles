.ONESHELL:
DOTFILES_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
all: vm packages macos-system-settings

include ./makefiles/*.mk

# defaults write org.hammerspoon.Hammerspoon MJConfigFile "~/.config/hammerspoon/init.lua"
# TODO: what does this doing
# xattr -d -r com.apple.quarantine ~/Library/QuickLook

# sudo sysctl -w kern.maxfiles=524288
# sudo sysctl -w kern.maxfilesperproc=524288
