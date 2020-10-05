
# On slow systems, checking the cached .zcompdump file to see if it must be
# regenerated adds a noticable delay to zsh startup.  This little hack restricts
# it to once a day.  It should be pasted into your own completion file.
#
# The globbing is a little complicated here:
# - '#q' is an explicit glob qualifier that makes globbing work within zsh's [[ ]] construct.
# - 'N' makes the glob pattern evaluate to nothing when it doesn't match (rather than throw a globbing error)
# - '.' matches "regular files"
# - 'mh+24' matches files (or directories or whatever) that are older than 24 hours.
# autoload -Uz compinit
# if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
# 	compinit;
# else
# 	compinit -C;
# fi;

# This is faster than `autoload -U compinit && compinit`
autoload -U +X bashcompinit && bashcompinit
autoload -Uz compinit

zcompdump_current() {
  if [[ $(uname -s) == 'Darwin' ]]; then
    [ "$(date +'%s')" != "$(stat -f '%Y' -t '%j' $HOME/.zcompdump)" ];
  else
    [ "$(date +'%s')" != "$(stat -c '%Y' $HOME/.zcompdump)" ];
  fi
}

if zcompdump_current; then
  compinit
else
  compinit -C
fi
