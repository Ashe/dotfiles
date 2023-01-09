----------------------------------
-- telescope
----------------------------------

require('telescope').setup({})


-- Keybindings

-- git_files, but falls back to find_files if not in a git repo
project_files = function()
  local opts = {}
  vim.fn.system('git rev-parse --is-inside-work-tree')
  if vim.v.shell_error == 0 then
    require"telescope.builtin".git_files(opts)
  else
    require"telescope.builtin".find_files(opts)
  end
end

local builtin = require('telescope.builtin')
which_key.register({ f = { name = "Find.." } }, { prefix = "<leader>" })
which_key.register({ G = { name = "Git.." } }, { prefix = "<leader>f" })
vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = "Search buffers" })
vim.keymap.set('n', '<C-p>', project_files, { desc = "Project files" })
vim.keymap.set('n', '<C-S-p>', builtin.builtin, { desc = "Builtins" })
vim.keymap.set('n', '<leader>?', builtin.builtin, { desc = "Builtins" })

vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = "Files" })
vim.keymap.set('n', '<leader>fr', builtin.oldfiles, { desc = "Recent files" })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = "Live grep" })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = "Help tags" })
vim.keymap.set('n', '<leader>fc', builtin.commands, { desc = "Commands" })
vim.keymap.set('n', '<leader>fH', builtin.help_tags, { desc = "Command history" })

vim.keymap.set('n', '<leader>fGS', builtin.git_stash, { desc = "Git stash" })
vim.keymap.set('n', '<leader>fGs', builtin.git_status, { desc = "Git status" })
vim.keymap.set('n', '<leader>fGb', builtin.git_branches, { desc = "Git branches" })
vim.keymap.set('n', '<leader>fGC', builtin.git_bcommits, { desc = "Git commits for buffer" })
vim.keymap.set('n', '<leader>fGc', builtin.git_commits, { desc = "Git commits" })
