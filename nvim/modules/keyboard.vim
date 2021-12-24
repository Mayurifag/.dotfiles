" https://thevaluable.dev/vim-for-beginners/
noremap <Up> <Nop>
noremap <Down> <Nop>
noremap <Left> <Nop>
noremap <Right> <Nop>
set clipboard+=unnamedplus

nnoremap <C-n> :NERDTree<CR>
nnoremap <C-t> :NERDTreeToggle<CR> " Ctrl+N = NERDTree
nnoremap <C-g> :NERDTreeFocus<CR>
inoremap <expr> <Tab> pumvisible() ? coc#_select_confirm() : "<Tab>"
