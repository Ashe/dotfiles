" Start loading plugins
call plug#begin('~/.config/nvim/plugged')

" Neovim specific
if has('nvim')

  " Enable mouse control
  set mouse=a

  " Code completion plugin
  Plug 'Shougo/deoplete.nvim', { 'do' : ':UpdateRemotePlugins' }

  " Haskell tools
  Plug 'parsonsmatt/intero-neovim'

" Vim specific
else
  " Code completion plugins
  Plug 'Shougo/deoplete.nvim'
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'
endif

" Fuzzy search
Plug 'kien/ctrlp.vim'

" Linting plugin
Plug 'w0rp/ale'

" GDScript plugin
Plug 'calviken/vim-gdscript3'

" Haskell plugins
Plug 'neovimhaskell/haskell-vim'

" Clojure plugins
Plug 'guns/vim-clojure-static'
Plug 'guns/vim-clojure-highlight'
Plug 'tpope/vim-fireplace'

" Show git additions in gutter
Plug 'airblade/vim-gitgutter'

" Airline
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Initialise plugin system
call plug#end()

" Place swap files in ~/.vim-tmp/
set backup
set swapfile
set backupdir=~/.vim-tmp
set directory=~/.vim-tmp

"Airline configuration
let g:airline_powerline_fonts=1
let g:airline_theme='deus'

" Set colour scheme
colorscheme dracula

" Enable syntax detection
syntax on

" Set line wrapping on 100 characters
set columns=100
set linebreak

" Show column guideline to keep code within 80 lines
set colorcolumn=80

" Spellchecking
set spelllang=en

" Make terminal title same as the file you're editing
set title

" Indent depending on plugins and filetype
filetype plugin indent on

" Set leader key to space
let mapleader = " "

" Save file with leader-w
nnoremap <leader>w  :w<CR>

" Copy to clipboard
set clipboard+=unnamedplus
vnoremap  <leader>y "+y
nnoremap  <leader>Y "+yg_
nnoremap  <leader>y "+y

" Paste from clipboard
nnoremap <leader>p "+p
nnoremap <leader>P "+P
vnoremap <leader>p "+p
vnoremap <leader>P "+P

" Tabs are 4 spaces
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab

" Relative line numbers
set number
set relativenumber

" Autocomplete interface
set wildmenu

" Make vim only redraw when needed
set lazyredraw

" Show matching parenthesis
set showmatch

" Start autocompleting using tab to cycle
let g:deoplete#enable_at_startup=1
inoremap <silent><expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"
inoremap <silent><expr><s-tab> pumvisible() ? "\<c-p>" : "\<s-tab>"

" Intero for Haskell
augroup haskell
  if has('nvim')
    au!
    " Background process and window management
    au FileType haskell nnoremap <silent> <leader>s :InteroStart<CR>
    au FileType haskell nnoremap <silent> <leader>S :InteroKill<CR>
    au FileType haskell nnoremap <silent> <leader>o :InteroOpen<CR>
    au FileType haskell nnoremap <silent> <leader>O :InteroHide<CR>
    au FileType haskell nnoremap <silent> <leader>r :InteroReload<CR>
    au FileType haskell nnoremap <silent> <leader>f :InteroGoToDef<CR>
    au FileType haskell nnoremap <silent> <leader>c :InteroLoadCurrentFile<CR>
    au FileType haskell nnoremap <silent> <leader>C :InteroLoadCurrentModule<CR>
    au FileType haskell map <silent> <leader>t <Plug>InteroGenericType
    au FileType haskell map <silent> <leader>T <Plug>InteroType
  endif
augroup END

" Change linters for ALE
 let g:ale_linters = {
 \ 'haskell': ['stack-ghc-mod', 'hlint'],
 \ 'cpp' : ['gcc', 'flawfinder']
 \}
