# Enhanced make cmd
_enhanced_make_completion() {
  local dir="$PWD" depth
  for depth in {0..3}; do
    [[ "$dir" == / ]] && break
    if [[ -f "$dir/Makefile" || -f "$dir/makefile" ]]; then
      # Filter file targets, variable assignments, and Makefile itself.
      local -a targets
      targets=("${(@f)$(cd "$dir" && command make -qp | \
        awk -F':' '/^[a-zA-Z0-9][^$#\/\t=]*:([^=]|$)/ {split($1,A,/ /);for(i in A)print A[i]}' | \
        grep -vE '^(Makefile|makefile)$')}")
      compadd -- $targets
      return
    fi
    dir=${dir:h}
  done
}

compdef _enhanced_make_completion make
