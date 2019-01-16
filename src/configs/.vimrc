call plug#begin('~/.local/share/nvim/plugged')

Plug 'tpope/vim-surround'

Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

" Plug 'phanviet/vim-monokai-pro'
Plug 'neutaaaaan/iosvkem'

Plug 'tomtom/tcomment_vim'

Plug 'leafgarland/typescript-vim'

Plug 'tpope/vim-eunuch'

Plug 'tpope/vim-rsi'

Plug 'tpope/vim-sleuth'

Plug 'sbdchd/neoformat'

Plug 'neovimhaskell/haskell-vim'

Plug 'ervandew/supertab'
let g:SuperTabDefaultCompletionType = "<c-n>"

" 'vitality'

Plug 'tpope/vim-abolish'

Plug 'tpope/vim-vinegar'
set wildignore+=.git/,.DS_Store

Plug '907th/vim-auto-save'
let g:auto_save = 0

Plug 'AndrewRadev/sideways.vim'
nnoremap (( :SidewaysLeft<cr>
nnoremap )) :SidewaysRight<cr>

Plug 'Shougo/deoplete.nvim'
let g:deoplete#enable_at_startup = 1

Plug 'christoomey/vim-tmux-navigator'

" Plug 'parsonsmatt/intero-neovim'

Plug 'elmcast/elm-vim'
let g:elm_setup_keybindings = 0

call plug#end()


""""""""""""""""""""""""""""""

let mapleader = ","

nnoremap <c-p> :Files<cr>
nnoremap <Leader>a :Ag<cr>
command! -bang -nargs=* Ag call fzf#vim#ag(<q-args>, {'options': '--delimiter : --nth 4..'}, <bang>0)

" Window management
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
set splitright
set splitbelow

" Quick changes to vimrc
nnoremap <Leader>ev :vsplit ~/.vimrc<cr>
nnoremap <Leader>sv :source $MYVIMRC<cr>

" Colors
set termguicolors
colorscheme iosvkem

" Neoformat on save and on ,f
augroup fmt
  autocmd!
  au BufWritePre * try | undojoin | Neoformat | catch /^Vim\%((\a\+)\)\=:E790/ | endtry
augroup END
nnoremap <Leader>f :Neoformat<cr>
 
" Searching
set hlsearch
set incsearch
set ignorecase
set smartcase

" Persistent undo
set undofile
set undodir=$HOME/.vim/undo
set undolevels=1000
set undoreload=10000

" Line numbers
set number

" Misc
nnoremap <Leader>qq :qa!<cr>
inoremap <C-c> <Esc>

" No arrows allowed
map <Left> :echo "no!"<cr>
map <Right> :echo "no!"<cr>
map <Up> :echo "no!"<cr>
map <Down> :echo "no!"<cr>

" Copy paste system clipboard
map <leader>y "*y
map <leader>p "*p
map <leader>P "*P
map <leader>gr "*gr

" Disable wrapping
set wrap!


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Below copied from Aaron Jensen: https://github.com/DerekMaffett/vimfiles/blob/master/plugin/expandwindows.vim
" I kinda know how it works but not completely
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Make the window we're on as big as it makes sense to make it
set winwidth=84

" We have to have a winheight bigger than we want to set winminheight. But if
" we set winheight to be huge before winminheight, the winminheight set will
" fail.
set winheight=5
set winminheight=5
set winheight=999

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Special window size hack
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! ResizeWindow()
  if &previewwindow
    set winheight=999
  elseif &buftype == 'quickfix'
    set winheight=10
  else
    set winheight=999
  endif
endfunction
autocmd WinEnter * call ResizeWindow()

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""