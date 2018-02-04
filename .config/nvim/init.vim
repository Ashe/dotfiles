" Start loading plugins
call plug#begin('~/.config/nvim/plugged')

" Neovim specific
if has('nvim')

        " Enable mouse control
        set mouse=a

        " Code completion plugin
        Plug 'Shougo/deoplete.nvim', { 'do' : ':UpdateRemotePlugins' }

        " Haskell plugin
        Plug 'parsonmatt/intero-neovim'

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

" Haskell plugins
Plug 'neovimhaskell/haskell-vim'
Plug 'alx741/vim-hindent'

" Show git additions in gutter
Plug 'airblade/vim-gitgutter'

" Airline
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Initialise plugin system
call plug#end()

"Airline configuration
let g:airline_powerline_fonts=1
let g:airline_theme='deus'

" Enable syntax detection
syntax on

" Indent depending on plugins and filetype
filetype plugin indent on

" Tabs are 4 spaces
set tabstop=4
set shiftwidth=4
set softtabstop=4
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
let g:deoplete#enable_at_startup = 1
inoremap <silent><expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"
inoremap <silent><expr><s-tab> pumvisible() ? "\<c-p>" : "\<s-tab>"

" Haskell, hindent config
g:hindent_indent_size = 2
