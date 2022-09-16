" =======================================================
" General
" =======================================================

" Enable mouse control
set mouse=a

" Place swap files in ~/.vim-tmp/
set backup
set swapfile
set backupdir=~/.vim-tmp
set directory=~/.vim-tmp

" Enable syntax highlighting
syntax on

" Show column guideline to keep code within 80 lines
set textwidth=0
set wrapmargin=0
set wrap
set linebreak
set colorcolumn=81

" Spellchecking
set spelllang=en

" Make terminal title same as the file you're editing
set title

" Indent depending on plugins and filetype
filetype plugin indent on

" Tabs are 2 spaces
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

" Don't pass messages to |ins-completion-menu|
set shortmess+=c

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved
set signcolumn=yes

" =======================================================
" Keybindings
" =======================================================

" Set leader key to space
let mapleader = " "

" Save file with leader-w
nnoremap <leader>w :w<CR>

" Copy to clipboard
set clipboard+=unnamedplus
vnoremap <leader>y "+y
nnoremap <leader>Y "+yg_
nnoremap <leader>y "+y

" Paste from clipboard
nnoremap <leader>p "+p
nnoremap <leader>P "+P
vnoremap <leader>p "+p
vnoremap <leader>P "+P
