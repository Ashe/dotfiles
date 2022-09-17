" ================================
" nvim-tree
" ================================

lua << EOF

-- Disable netrw at the very start of your init.lua (strongly advised)
vim.g.loaded = 1
vim.g.loaded_netrwPlugin = 1

-- Empty setup using defaults
require('nvim-tree').setup()

EOF

let mapleader = " "
nnoremap <A-o> <cmd>NvimTreeToggle<cr>
nnoremap <leader>fo <cmd>NvimTreeToggle<cr>
