# ===== Basics
setopt no_beep # don't beep on error
setopt interactive_comments # Allow comments even in interactive shells (especially for Muness)

# ===== Changing Directories
# setopt auto_cd # If you type foo, and it isn't a command, and it is a directory in your cdpath, go there
# setopt cdablevars # if argument to cd is the name of a parameter whose value is a valid directory, it will become the current directory
# setopt pushd_ignore_dups # don't push multiple copies of the same directory onto the directory stack

# ===== Expansion and Globbing
setopt extended_glob # treat #, ~, and ^ as part of patterns for filename generation

# ===== History
setopt append_history         # Append to history file, don't overwrite
setopt hist_expire_dups_first # When trimming history, lose oldest duplicates first
setopt hist_find_no_dups      # When searching, don't display duplicates
setopt hist_ignore_dups       # Don't record commands that are duplicates of previous one
setopt hist_ignore_space      # Don't record commands starting with a space
setopt hist_reduce_blanks     # Remove extra blanks from commands
setopt hist_verify            # Show command from history before executing
setopt inc_append_history     # Write to history file immediately, not at shell exit
setopt share_history          # Share history between all sessions

# ===== Completion
setopt always_to_end # When completing from the middle of a word, move the cursor to the end of the word
setopt auto_menu # show completion menu on successive tab press. needs unsetop menu_complete to work
setopt auto_name_dirs # any parameter that is set to the absolute name of a directory immediately becomes a name for that directory
setopt complete_in_word # Allow completion from within a word/phrase

unsetopt menu_complete # do not autoselect the first completion entry

# ===== Correction
setopt correct # spelling correction for commands
#setopt correctall # spelling correction for arguments

# ===== Prompt
setopt prompt_subst # Enable parameter expansion, command substitution, and arithmetic expansion in the prompt
setopt transient_rprompt # only show the rprompt on the current prompt

# ===== Scripts and Functions
setopt multios # perform implicit tees or cats when multiple redirections are attempted

setopt hash_list_all            # hash everything before completion
setopt completealiases          # complete alisases
setopt list_ambiguous           # complete as much of a completion until it gets ambiguous.
setopt auto_remove_slash        # self explicit
setopt chase_links              # resolve symlinks
setopt no_nomatch # if there are no matches for globs, leave them alone and execute the command
