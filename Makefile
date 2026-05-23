.ONESHELL:
ifeq ($(OS),Windows_NT)
SHELL := sh
endif

DOTFILES_DIR := $(patsubst %/,%,$(dir $(realpath $(firstword $(MAKEFILE_LIST)))))

include ./makefiles/*.mk
