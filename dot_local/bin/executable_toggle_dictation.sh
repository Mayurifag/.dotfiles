#!/bin/bash

set -Eeuo pipefail

main() {
  if pgrep -f "nerd-dictation" > /dev/null
  then
      nerd-dictation end
  else
      nerd-dictation begin --simulate-input-tool YDOTOOL
  fi
}

main "$@"
