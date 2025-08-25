pollCommand() {
    while true; do clear; $@; sleep 1; done
}

prg() {
  git pull -a > /dev/null

  local branches=$(git branch --list '*[^master][^main]' --format='%(refname:short)' | grep -v '^*')
  branches=(${branches//;/ })

  if [ -z $branches ]; then
    echo 'No branches to delete.'
    return;
  fi

  echo $branches

  echo 'Do you want to delete these merged branches? (y/n)'
  read yn
  case $yn in
      [^Yy]* ) return;;
  esac

  git remote prune origin
  echo $branches | xargs git branch -D
}

if command -v systemctl &> /dev/null; then
  start() {
    sudo systemctl start $1.service
  }
  restart() {
    sudo systemctl restart $1.service
  }
  stop() {
    sudo systemctl stop $1.service
  }
  enable() {
    sudo systemctl enable $1.service
  }
  status() {
    sudo systemctl status $1.service
  }
  disable() {
    sudo systemctl disable $1.service
  }
fi

# Create a new directory and enter it
mkcd() { [ -n "$1" ] && mkdir -p "$@" && builtin cd "$1"; }
backup() { cp "$1"{,.bak};}

if command -v aspell &> /dev/null; then
  # Usage: spl paranoya
  # & paranoya 8 0: paranoia, Parana, paranoiac (as you see the first option after the 0, gives the correct spelling
  spl () {
    aspell -a <<< "$1"
  }
fi

# Delete a given line number in the known_hosts file.
# Alternative: ssh-keygen -R 182.123.212.21
knownrm() {
  re='^[0-9]+$'
  if ! [[ $1 =~ $re ]] ; then
    echo "error: line number missing" >&2;
  else
    sed -i '' "$1d" ~/.ssh/known_hosts
  fi
}

gcd() {
  git clone --recurse-submodules "$1" && builtin cd "$(basename "$1" .git)"
}

grom () {
  if git rev-parse --verify --quiet origin/main > /dev/null 2>&1; then
    GIT_BRANCH=main
  elif git rev-parse --verify --quiet origin/master > /dev/null 2>&1; then
    GIT_BRANCH=master
  elif git rev-parse --verify --quiet origin/source > /dev/null 2>&1; then
    GIT_BRANCH=source
  else
    echo "Neither 'origin/main' nor 'origin/master' branch exists."
    return 1
  fi

  LEFTHOOK=0 git rebase -i "origin/$GIT_BRANCH"
  git submodule update --init --recursive
}

remove_audio() {
  ffmpeg -i $1 -c copy -an onlyVideo.mp4
}

ports() {
  sudo lsof -iTCP -sTCP:LISTEN -n -P | awk 'NR>1 {print $9, $1, $2}' | sed 's/.*://' | while read port process pid; do echo "Port $port: $(ps -p $pid -o command= | sed 's/^-//') (PID: $pid)"; done | sort -n
}

killport() {
  kill -9 "$(lsof -t -i:"${1}" -sTCP:LISTEN)"
}

# Function to open Cursor, automatically with dev container if available
f() {
  code .

  sleep 3 # I am trying to make sure that Gemini Coder extension will work fine when both windows are opened

  local devcontainer_file=".devcontainer/devcontainer.json"

  if [ -f "$devcontainer_file" ] && command -v jq &> /dev/null; then
    local default_workspace_folder="/workspace"
    local container_workspace_folder
    container_workspace_folder=$(jq -r '.workspaceFolder' "$devcontainer_file")

    if [ "$container_workspace_folder" = "null" ] || [ -z "$container_workspace_folder" ]; then
      echo "Warning: '.workspaceFolder' not found or empty in $devcontainer_file. Defaulting to '$default_workspace_folder'." >&2
      container_workspace_folder="$default_workspace_folder"
    fi

    local folder_path
    folder_path=$(pwd) # Get the absolute path of the current directory

    # Ensure xxd command is available for hex encoding
    if ! command -v xxd &> /dev/null; then
        echo "Error: xxd command not found. Please install it (e.g., using 'brew install vim' or 'sudo apt-get install xxd')." >&2
        return 1
    fi

    # Hex-encode the host folder path
    local hex_path
    hex_path=$(echo -n "$folder_path" | xxd -p | tr -d '\n')

    # Construct the URI
    local uri="vscode-remote://dev-container+${hex_path}${container_workspace_folder}"

    code --folder-uri "$uri"
  fi
}

mr() {
  local diff_content="You are reviewing the following git diff from my codebase.
Your job is **NOT to invent** new changes, but to **analyze only the code changes shown in the git diff below**.

Task:

1 Propose improvements to these changes, if any, in the form of exact edits — using imperative mood, e.g., \"Replace X with Y\", \"Remove this block and use Z instead\".
2 Later you might be proposed to output the exact files instead of brief summary.
3 Do NOT comment on unchanged files or say things like \"this looks good\".

Be concise and exact. Your feedback will be used to improve the shown changes, not create new ones from scratch.

Below is my current git diff — these are changes I already made and want to improve:

$(git diff HEAD)

---

Do NOT output full files unless I respond with \"QWE\" or \"ЙЦУ\". You are supposed to not output any new comment or docstring and also remove the obvious ones. Here is the format I need after confirmation:"

  echo "$diff_content" | pbcopy
  echo "Code review template with git diff copied to clipboard"
}

# Move a file or directory and create a symbolic link at the original location
# pointing to the new location.
# Usage: mvln <source> <destination>
mvln() {
  if [ "$#" -ne 2 ]; then
    echo "Usage: mvln <source> <destination>" >&2
    return 1
  fi

  local source="${1%/}" # Ensure no trailing slash on source
  local dest="$2"
  local source_base
  source_base=$(basename "$source")

  if [ ! -e "$source" ]; then
    echo "mvln: source '$source' does not exist" >&2
    return 1
  fi

  # Determine the final path of the moved source
  local target_path
  if [ -d "$dest" ]; then
    # Destination is a directory, so the final path will be inside it.
    target_path="${dest%/}/$source_base"
  else
    # Destination is a file path.
    target_path="$dest"
  fi

  # Perform the move
  if mv -v "$source" "$dest"; then
    # After a successful move, create the symlink.
    # We need the absolute path of the new location for the symlink.
    local abs_target_path
    # This correctly resolves the absolute path regardless of whether target_path is relative or absolute.
    abs_target_path="$(cd "$(dirname "$target_path")" && pwd)/$(basename "$target_path")"

    # Link back to the original source path
    ln -s "$abs_target_path" "$source"
  else
    echo "mvln: 'mv' command failed." >&2
    return 1
  fi
}

lnsf() {
  if [[ -f "$1" ]]; then
    ln -sf "$1" "$2"
  elif [[ -L "$2" && ! -e "$2" ]]; then # If the source is missing, remove a broken link if it exists
    rm -f "$2"
  fi
}

cleaner() {
  # Helper function to ask for confirmation
  _cleaner_confirm() {
    local prompt="$1 (Y/n) "
    local response
    read "response?$prompt"
    if [[ "$response" == "n" || "$response" == "N" ]]; then
      return 1
    fi
    return 0
  }

  # Docker
  if command -v docker &> /dev/null; then
    if _cleaner_confirm "Clean unused Docker images, containers, volumes, and networks?"; then
      echo "Cleaning Docker..."
      docker system prune -a --volumes
    fi
  fi

  # yay (Arch Linux)
  if command -v yay &> /dev/null; then
    if _cleaner_confirm "Clean yay cache?"; then
      echo "Cleaning yay cache..."
      yay -Scc
    fi
  fi

  # Homebrew (macOS)
  if command -v brew &> /dev/null; then
    if _cleaner_confirm "Clean up Homebrew?"; then
      echo "Cleaning up Homebrew..."
      brew cleanup
    fi
  fi

  # mise
  if command -v mise &> /dev/null; then
    if _cleaner_confirm "Clear mise cache?"; then
      echo "Clearing mise cache..."
      mise cache clear
    fi
  fi

  # npm
  if command -v npm &> /dev/null; then
    if _cleaner_confirm "Clean npm cache?"; then
      echo "Cleaning npm cache..."
      npm cache clean --force
    fi
  fi

  # uv
  if command -v uv &> /dev/null; then
    if _cleaner_confirm "Clean uv cache?"; then
      echo "Cleaning uv cache..."
      uv cache clean
    fi
  fi

  echo "Cleaning process finished."
}

# enhanced make command that finds Makefile in parent directories
make() {
  local original_dir
  original_dir=$(pwd)
  local current_dir
  current_dir=$(pwd)
  local makefile_found_dir=""
  local search_depth=0
  local max_depth=3 # Search current directory + 3 parents

  while [[ "$current_dir" != "/" && -z "$makefile_found_dir" && "$search_depth" -le "$max_depth" ]]; do
    if [[ -f "$current_dir/Makefile" ]] || [[ -f "$current_dir/makefile" ]]; then
      makefile_found_dir="$current_dir"
      break
    fi
    current_dir=$(dirname "$current_dir")
    (( search_depth++ ))
  done

  if [[ -n "$makefile_found_dir" ]]; then
    if [[ "$makefile_found_dir" != "$original_dir" ]]; then
      # Inform user about the change of directory, redirecting to stderr
      echo "Makefile found in: $makefile_found_dir" >&2
    fi

    # Execute in a subshell to avoid changing the current directory
    (cd "$makefile_found_dir" && command make "$@")
  else
    echo "No Makefile found in current or parent directories." >&2
    # Fallback to default make behavior, it will show its own error
    command make "$@"
    return 1
  fi
}
