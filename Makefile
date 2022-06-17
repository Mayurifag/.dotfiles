.ONESHELL:

all: macos link vm packages

include ./makefiles/*.mk

# defaults write org.hammerspoon.Hammerspoon MJConfigFile "~/.config/hammerspoon/init.lua"
# TODO: what does this doing
# xattr -d -r com.apple.quarantine ~/Library/QuickLook

# sudo sysctl -w kern.maxfiles=524288
# sudo sysctl -w kern.maxfilesperproc=524288
