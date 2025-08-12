----------------------------------
-- telescope
----------------------------------

require('telescope').setup({

  -- Change default mappings when in window
  defaults = {
    mappings = {

      i = {
        -- Preview window mappings for insert mode
        ["<C-f>"] = false,
        ["<C-u>"] = "preview_scrolling_up",
        ["<C-d>"] = "preview_scrolling_down",
        ["<C-k>"] = "preview_scrolling_up",
        ["<C-j>"] = "preview_scrolling_down",
        ["<C-h>"] = "preview_scrolling_left",
        ["<C-l>"] = "preview_scrolling_right",
      },
      n = {
        -- Preview window mappings for normal mode
        ["<C-f>"] = false,
        ["<C-u>"] = "preview_scrolling_up",
        ["<C-d>"] = "preview_scrolling_down",
        ["<C-k>"] = "preview_scrolling_up",
        ["<C-j>"] = "preview_scrolling_down",
        ["<C-h>"] = "preview_scrolling_left",
        ["<C-l>"] = "preview_scrolling_right",
      }
    }
  }
})


-- Keybindings

-- git_files, but falls back to find_files if not in a git repo
project_files = function()
  local opts = {}
  vim.fn.system('git rev-parse --is-inside-work-tree')
  if vim.v.shell_error == 0 then
    require('telescope.builtin').git_files(opts)
  else
    require('telescope.builtin').find_files(opts)
  end
end

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = "Search buffers" })
vim.keymap.set('n', '<C-p>', project_files, { desc = "Project files" })
vim.keymap.set('n', '<C-S-p>', builtin.builtin, { desc = "Telescope builtins" })

require('which-key').add({{ "<leader>f", group = "Find.." }})
vim.keymap.set('n', '<leader>fT', builtin.builtin, { desc = "Telescope builtins" })
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = "Files" })
vim.keymap.set('n', '<leader>fR', builtin.oldfiles, { desc = "Recent files" })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = "Live grep" })
vim.keymap.set('n', '<leader>fG', builtin.registers, { desc = "Registers" })
vim.keymap.set('n', '<leader>fc', builtin.command_history, { desc = "Command history" })
vim.keymap.set('n', '<leader>f/', builtin.search_history, { desc = "Search history" })

require('which-key').add({{ "<leader>fv", group = "Vim.." }})
vim.keymap.set('n', '<leader>fvc', builtin.commands, { desc = "Commands" })
vim.keymap.set('n', '<leader>fvk', builtin.keymaps, { desc = "Keymaps" })
vim.keymap.set('n', '<leader>fvo', builtin.vim_options, { desc = "Options" })
vim.keymap.set('n', '<leader>fvh', builtin.help_tags, { desc = "Help tags" })

require('which-key').add({{ "<leader>g", group = "Git.." }})
vim.keymap.set('n', '<leader>gS', builtin.git_stash, { desc = "Git stash" })
vim.keymap.set('n', '<leader>gs', builtin.git_status, { desc = "Git status" })
vim.keymap.set('n', '<leader>gb', builtin.git_branches, { desc = "Git branches" })
vim.keymap.set('n', '<leader>gC', builtin.git_bcommits, { desc = "Git commits for buffer" })
vim.keymap.set('n', '<leader>gc', builtin.git_commits, { desc = "Git commits" })
