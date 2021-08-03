# Development
## Local binaries
export PATH="$HOME/.local/bin:$PATH"

if type rg &> /dev/null; then
  export FZF_DEFAULT_COMMAND='rg --files --hidden'
  export FZF_DEFAULT_OPTS='-m --height 50% --border'
fi
