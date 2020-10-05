[ -f $HOME/.zsh_plugins.sh ] && source $HOME/.zsh_plugins.sh # Load zsh plugins

setopt hash_list_all            # hash everything before completion
setopt completealiases          # complete alisases
setopt always_to_end            # when completing from the middle of a word, move the cursor to the end of the word
setopt complete_in_word         # allow completion from within a word/phrase
setopt list_ambiguous           # complete as much of a completion until it gets ambiguous.
setopt auto_remove_slash        # self explicit
setopt chase_links              # resolve symlinks

# History
HISTSIZE=10000 # Lines of history to keep in memory for current session
HISTFILESIZE=10000 # Number of commands to save in the file
SAVEHIST=10000 # Number of history entries to save to disk
HISTFILE=~/.zsh_history # Where to save history to disk
HISTDUP=erase # Erase duplicates in the history file
setopt hist_ignore_dups # Ignore duplicates

setopt NO_NOMATCH

# Options - `man zshoptions`
setopt append_history # Append history to the history file (no overwriting)
setopt share_history # Share history across terminals
setopt inc_append_history # Immediately append to the history file, not just when a term is killed
setopt extended_glob # Use extended globbing syntax
setopt auto_cd # Auto change to a dir without typing cd

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

export KEYTIMEOUT=1 # Shorter delay typing https://www.johnhawthorn.com/2012/09/vi-escape-delays/

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

DISABLE_AUTO_UPDATE="true"

# Update Zsh plugins
uz(){
  antibody bundle <~/.dotfiles/zsh/plugins.txt >~/.zsh_plugins.sh
  antibody update
}

bindkey "^[[3~" delete-char

_evalcache dip console
