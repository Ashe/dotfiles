" ================================
" General
" ================================

" Enable mouse control
set mouse=a

" Place swap files in ~/.vim-tmp/
set backup
set swapfile
set backupdir=~/.vim-tmp
set directory=~/.vim-tmp

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

" Don't show '~'
set fillchars=fold:\ ,vert:\│,eob:\ ,msgsep:‾

lua << EOF

----------------------------------
-- Keybindings
----------------------------------

-- Set leader key to space
vim.g.mapleader = " "

-- Reload neovim config
vim.keymap.set("n", "<leader><S-BS>", ":so ~/.config/nvim/init.lua<CR>", { desc="Reload config" })

-- Save file with leader-w
vim.keymap.set("n", "<leader>w", ":w<CR>", { desc="Save file" })

-- Copy to clipboard
vim.opt.clipboard:append { "unnamed", "unnamedplus" }
vim.keymap.set({"n", "v"}, "<leader>y", "\"+y", { desc="Copy" })
vim.keymap.set("n", "<leader>Y", "\"+yg_", { desc="Copy rest" })

-- Paste from clipboard
vim.keymap.set({"n", "v"}, "<leader>P", "\"+P", { desc="Paste before" })
vim.keymap.set({"n", "v"}, "<leader>p", "\"+p", { desc="Paste after" })

-- Delete into the void
vim.keymap.set({"n", "v"}, "<leader>d", "\"_d", { desc="Void delete" })
vim.keymap.set("n", "<leader>D", "_\"_d$", { desc="Void line to void" })

-- Move block up and down
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc="Move block up" })
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc="Move block down" })

-- Keep cursor in middle of screen when half-page-jumping
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc="Half-page up" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc="Half-page down" })

-- Set up text replacement macro
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc="Substitute" })

----------------------------------
-- Appearance
----------------------------------

local ok, _ = pcall(vim.cmd, 'colorscheme <COLOURSCHEME>')
if not ok then
  vim.cmd 'colorscheme default'
end

----------------------------------
-- Plugin-preparation
----------------------------------

-- nvim-tree: Disable netrw at the very start of your init.lua (strongly advised)
vim.g.loaded = 1
vim.g.loaded_netrwPlugin = 1

EOF
