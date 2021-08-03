. $HOME/.asdf/asdf.sh

# _evalcache dip console

## Golang
GOV=$(asdf where golang)
export GOROOT=$GOV/go
export GOPATH=$HOME/go
export PATH="$PATH:$GOPATH/bin"
export PATH=$PATH:$GOPATH/bin
