----------------------------------
-- nvim-tree
----------------------------------

-- Empty setup using defaults
require('nvim-tree').setup()


-- Keybindings

local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- Move to previous/next
map('n', '<leader>fo', '<Cmd>NvimTreeToggle<CR>', opts)
map('n', '<A-o>', '<Cmd>NvimTreeToggle<CR>', opts)
