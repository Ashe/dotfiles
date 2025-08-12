----------------------------------
-- nvim-tree
----------------------------------

-- Empty setup using defaults
require('nvim-tree').setup()


-- Keybindings

-- Move to previous/next
vim.keymap.set('n', '<leader>fo', '<Cmd>NvimTreeToggle<CR>', { desc = "Open file tree" })
vim.keymap.set('n', '<A-o>', '<Cmd>NvimTreeToggle<CR>', { desc = "Open file tree" })
