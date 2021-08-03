filetype plugin indent on
syntax enable

set encoding=utf-8
set nocompatible
" set guifont=JetBrains\ Mono\ Medium\ Nerd\ Font\ Complete:h14
set wrap linebreak nolist " Wrap long lines

set showmatch         " Show matching braces
set hlsearch          " switch on highlighting for the last used search pattern
set showcmd           " display incomplete commands
set mat=1             " Set the time to show matching braces to 1 second
set ignorecase        " Ignore case on searches
set smartcase         " Use case sensitive search if there is a capital letter in the search
set undolevels=10000  " Set the number of undos that are remembered
set number            " Show line numbers
set tabstop=2         " Use 2 space tabs
set shiftwidth=2      " Use 2 space tabs
set incsearch         " Incremental search: jump to the first occurrence of search while the user is still searching
set mouse=a           " Enable the mouse
set autoindent        " Use autoindentation
set splitbelow        " Make horizontal splits below instead of above
set splitright        " Make vertical splits on the right
set scrolloff=3       " Start scrolling when the cursor is 3 lines away from the bottom of the window
set laststatus=2      " Always display the status line
set cursorline        " Highlight the current line
set autoread          " Automatically reload the file when it is changed from an outside program
set nohlsearch        " Don't highlight search results
set expandtab         " Use spaces instead of tabs
set termguicolors

" undo shit after weeks
set undodir=~/.vim/undodir
set undofile
