set runtimepath+=~/.vim_runtime

source ~/.vim_runtime/vimrcs/basic.vim
source ~/.vim_runtime/vimrcs/filetypes.vim
source ~/.vim_runtime/vimrcs/plugins_config.vim
source ~/.vim_runtime/vimrcs/extended.vim

" Set color of Vim
colorscheme peaksea
syntax enable

" Indent depending on filetype (eg. py)
filetype indent on

" Tabs are 4 spaces
set tabstop=4
set softtabstop=4
set expandtab

" Relative line numbers
set number
set relativenumber

" Make current line stand out
set cursorline

" Autocomplete interface
set wildmenu

" Make Vim only redraw when needed
set lazyredraw

" Show matching parenthesis
set showmatch

" Highlight search results
set incsearch
set hlsearch
