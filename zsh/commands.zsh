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
mkcd() {   [ -n "$1" ] && mkdir -p "$@" && builtin cd "$1";   }

pskill(){
    ps aux | grep "$1" | grep -v grep | awk '{print $2;}' | while read p; do kill -9 $p; done
}

backup() { cp "$1"{,.bak};}

# -------------------------------------------------------------------
# compressed file expander
# (from https://github.com/myfreeweb/zshuery/blob/master/zshuery.sh)
# -------------------------------------------------------------------
ex() {
    if [[ -f $1 ]]; then
        case $1 in
            *.tar.bz2) tar xvjf $1;;
            *.tar.gz) tar xvzf $1;;
            *.tar.xz) tar xvJf $1;;
            *.tar.lzma) tar --lzma xvf $1;;
            *.bz2) bunzip $1;;
            *.rar) unrar $1;;
            *.gz) gunzip $1;;
            *.tar) tar xvf $1;;
            *.tbz2) tar xvjf $1;;
            *.tgz) tar xvzf $1;;
            *.zip) unzip $1;;
            *.Z) uncompress $1;;
            *.7z) 7z x $1;;
            *.dmg) hdiutul mount $1;; # mount OS X disk images
            *) echo "'$1' cannot be extracted via >ex<";;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Usage: spl paranoya
# & paranoya 8 0: paranoia, Parana, paranoiac (as you see the first option after the 0, gives the correct spelling
spl () {
  aspell -a <<< "$1"
}

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

btrestart() {
  sudo rfkill block bluetooth && sleep 0.1 && sudo rfkill unblock bluetooth
}

# -i path/to/input_file: give the path to your file
# -c copy: tell FFmpeg to copy codecs (prevent transcoding)
# -an: disables audio
remove_audio() {
  ffmpeg -i $1 -c copy -an onlyVideo.mp4
}

leet() {
  filename=$(echo "$@" | tr ' ' '_' | tr '[:upper:]' '[:lower:]')
  mkdir -p ${filename}
  touch ${filename}/${filename}.go
  echo "package leetcode" >> ${filename}/${filename}.go
}

leetest() {
  gotests -w -all -parallel $1
}

ports() {
  sudo lsof -iTCP -sTCP:LISTEN -n -P | awk 'NR>1 {print $9, $1, $2}' | sed 's/.*://' | while read port process pid; do echo "Port $port: $(ps -p $pid -o command= | sed 's/^-//') (PID: $pid)"; done | sort -n
}

optimize-video() {
  local file="$1"
  local extension="${file##*.}"
  local basename="${file%.*}"

  # Temporary output file to avoid overwriting during the process
  local tmp_output="${basename}_converted.mp4"

  # Convert video with ffmpeg using h265 codec, slow preset, and audio settings
  ffmpeg -r 25 -i "$file" -c:v libx265 -preset slow -crf 28 -c:a aac -b:a 256k "$tmp_output"

  # Check if the conversion was successful, then delete the original file
  if [[ -f "$tmp_output" ]]; then
    rm "$file"
    mv "$tmp_output" "$file"
    echo "Converted and replaced: $file"
  else
    echo "Failed to convert: $file"
  fi
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

pkglist-explicit() {
  pacman -Qei | awk '/^Name/{name=$3} /^Install Date/{date=$4" "$5" "$6" "$7" "$8} /^Install Reason/{if($4=="Explicitly") print date, name}' | sort
}

pkglist() {
  pacman -Qe | awk '{print $1}' | sort
}
