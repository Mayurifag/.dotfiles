# This script handles Zsh completion system initialization (`compinit`).
# The goal is to be fast, robust, and automatically update when new
# completions are installed.
#
# Sources and Ideas:
# - The core logic avoids a full `compinit` on every shell startup by using a
#   cached dump file (`.zcompdump`), which significantly improves speed.
# - The cache is regenerated automatically when new completions are detected.
#   This is achieved by checking if any completion directories in `$fpath` have
#   been modified more recently than the dump file itself. This is a robust
#   method discussed by many in the Zsh community.
#   Source (explains the problem): https://www.moch.com/zsh-compinit-rtfm/ [3]
# - The dump file is compiled to `.zcompdump.zwc` for an additional speed boost.
#   This is done in the background so it doesn't slow down the prompt.
#   Source (for `zcompile` idea): https://alex-k-t.github.io/2018/07/23/faster-and-enjoyable-zsh.html [5]
# - This setup relies on Zsh plugins (like for `mise`, `brew`, etc.) to correctly
#   add their completion directories to the `$fpath` *before* this script runs.

autoload -Uz compinit

# Define the path for the completion dump file.
# Using a file in `${ZDOTDIR:-$HOME}` is standard practice.
_zcompdump_path="${ZDOTDIR:-$HOME}/.zcompdump"

# Decide if we need to regenerate the dump file.
local regenerate_dump=0
if [[ ! -f "$_zcompdump_path" ]]; then
  regenerate_dump=1
else
  # Check if any directory in fpath is newer than the dump file.
  for dir in $fpath; do
    # Check if the directory exists and is newer than the dump file.
    if [[ -d "$dir" && "$dir" -nt "$_zcompdump_path" ]]; then
      regenerate_dump=1
      break
    fi
  done
fi

# Perform `compinit`.
if [[ "$regenerate_dump" -eq 1 ]]; then
  # Regenerate the dump file. The `-i` option makes it ignore insecure files.
  compinit -i -d "$_zcompdump_path"
else
  # Load from the existing dump file, which is much faster.
  compinit -C -i -d "$_zcompdump_path"
fi

# Compile the dump file in the background if the compiled version
# is missing or older than the non-compiled version.
if [[ -s "$_zcompdump_path" && (! -s "$_zcompdump_path.zwc" || "$_zcompdump_path" -nt "$_zcompdump_path.zwc") ]]; then
  # The `{ ... } &!` block runs this command in the background,
  # so it doesn't delay the shell prompt.
  {
    zcompile -R -- "$_zcompdump_path"
  } &!
fi

# Clean up local variables.
unset _zcompdump_path regenerate_dump

# Enhanced make cmd
_enhanced_make_completion() {
  local makefile_dir=""
  local current_dir
  current_dir=$(pwd)
  local search_depth=0
  local max_depth=3 # Search current directory + 3 parents

  while [[ "$current_dir" != "/" && -z "$makefile_dir" && "$search_depth" -le "$max_depth" ]]; do
    if [[ -f "$current_dir/Makefile" ]] || [[ -f "$current_dir/makefile" ]]; then
      makefile_dir="$current_dir"
      break
    fi
    current_dir=$(dirname "$current_dir")
    (( search_depth++ ))
  done

  if [[ -n "$makefile_dir" ]]; then
    # A robust way to get make targets.
    # It filters out file-system targets, variable assignments and .PHONY stuff.
    # It now also filters out 'Makefile' and 'makefile' from the output.
    local -a targets
    targets=("${(@f)$(cd "$makefile_dir" && command make -qp | \
      awk -F':' '/^[a-zA-Z0-9][^$#\/\t=]*:([^=]|$)/ {split($1,A,/ /);for(i in A)print A[i]}' | \
      grep -vE '^(Makefile|makefile)$')}")
    compadd -- $targets
  fi
}

compdef _enhanced_make_completion make
