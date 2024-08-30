.ONESHELL:
DOTFILES_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
all: packages macos-system-settings

include ./makefiles/*.mk
