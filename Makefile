.ONESHELL:
DOTFILES_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

include ./makefiles/*.mk
