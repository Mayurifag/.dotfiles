# Development
## Local binaries
export PATH="$HOME/.local/bin:$PATH"

if type rg &> /dev/null; then
  export FZF_DEFAULT_COMMAND='rg --files --hidden'
  export FZF_DEFAULT_OPTS='-m --height 50% --border'
fi

# _evalcache dip console

# TODO: if installed android studio and asdf golang

## Golang
GOV=$(asdf where golang)
export GOROOT=$GOV/go
export GOPATH=$HOME/go
# export PATH="$PATH:$GOPATH/bin"
export PATH=$PATH:$GOPATH/bin

## Android (React Native)
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools
