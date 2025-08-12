----------------------------------
-- nvim-treesitter
----------------------------------

require('nvim-treesitter.configs').setup({

  -- Enable syntax highlighting
  highlight = { enable = true },

  -- Intelligently select code incrementally
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = '<c-space>',
      node_incremental = '<c-space>',
      scope_incremental = '<c-s>',
      node_decremental = '<c-backspace>',
    },
  },
})
