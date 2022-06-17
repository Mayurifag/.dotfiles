if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin("~/.vim/plugged")

Plug 'preservim/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'vim-airline/vim-airline' " bottom line prettified
Plug 'ryanoasis/vim-devicons' " airline/nerdtree icons

Plug 'cocopon/iceberg.vim'
Plug 'gkeep/iceberg-dark'

Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

Plug 'lyokha/vim-xkbswitch' " switch to en layout on exit from insert mode
Plug 'mhinz/vim-startify'
Plug 'editorconfig/editorconfig-vim'

Plug 'http://github.com/tpope/vim-surround' " Surrounding ysw)
Plug 'https://github.com/tpope/vim-commentary' " For Commenting gcc & gc
Plug 'https://github.com/terryma/vim-multiple-cursors' " CTRL + N for multiple cursors
call plug#end()
