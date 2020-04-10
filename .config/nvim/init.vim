" Start loading plugins
call plug#begin('~/.config/nvim/plugged')

" Enable mouse control
set mouse=a

" Navigate TMUX with vim
Plug 'christoomey/vim-tmux-navigator'

" Code completion plugin
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Fuzzy search
Plug 'ctrlpvim/ctrlp.vim'

" C# omnisharp plugin
Plug 'omnisharp/omnisharp-vim'

" GDScript plugin
Plug 'calviken/vim-gdscript3'

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

" Enable syntax detection
syntax on

" Set colourscheme
colorscheme theme

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

" Use tab for trigger completion with characters ahead and navigate
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion
inoremap <silent><expr> <c-space> coc#refresh()

" GoTo code navigation
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Highlight the symbol and its references when holding the cursor
autocmd CursorHold * silent call CocActionAsync('highlight')

" Use K to show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

" Formatting selected code
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

" Add (Neo)Vim's native statusline support
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" C# uses 4-space indents
augroup cs
  au FileType cs setlocal shiftwidth=4 tabstop=4 softtabstop=4 expandtab
augroup END

" Configure Omnisharp
let g:OmniSharp_server_stdio = 1

 " Configure exceptions for CTRLP
set wildignore+=*/tmp/*,*/bin/*,*/obj/*,*.so,*.swp,*.zi
