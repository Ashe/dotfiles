----------------------------------
-- telescope
----------------------------------

require('telescope').setup()

local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

map('n', '<leader><leader>', '<Cmd>Telescope buffers<CR>', opts)
map('n', '<C-p>', '<Cmd>Telescope git_files<CR>', opts)
map('n', '<leader>ff', '<Cmd>Telescope find_files<CR>', opts)
map('n', '<leader>fr', '<Cmd>Telescope oldfiles<CR>', opts)
map('n', '<leader>fg', '<Cmd>Telescope live_grep<CR>', opts)
map('n', '<leader>fh', '<Cmd>Telescope help_tags<CR>', opts)
map('n', '<leader>?', '<Cmd>Telescope commands<CR>', opts)
map('n', '<C-S-p>', '<Cmd>Telescope commands<CR>', opts)
