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
