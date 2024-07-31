----------------------------------
-- which-key
----------------------------------

require('which-key').setup({

  plugins = {

    -- Shows a list of your marks on ' and `
    marks = true,

    -- Shows your registers on " in NORMAL or <C-r> in INSERT mode
    registers = true,

    spelling = {

      -- Enabling this will show WhichKey when pressing z= to select spelling suggestions
      enabled = false,

      -- How many suggestions should be shown in the list?
      suggestions = 20,
    },

    -- The presets plugin:
    -- * Adds help for a bunch of default keybindings in Neovim
    -- * No actual key bindings are created
    presets = {

      -- Adds help for operators like d, y, ... and registers them for motion / text object completion
      operators = true,

      -- Adds help for motions
      motions = true,

      -- Help for text objects triggered after entering an operator
      text_objects = true,

      -- Default bindings on <c-w>
      windows = true,

      -- Misc bindings to work with windows
      nav = true,

      -- Bindings for folds, spelling and others prefixed with z
      z = true,

      -- Bindings for prefixed with g
      g = true,
    },
  },

  icons = {

    -- Symbol used in the command line area that shows your active key combo
    breadcrumb = "»",

    -- Symbol used between a key and it's label
    separator = "➜",

    -- Symbol prepended to a group
    group = "+ ",
  },

  win = {
    -- None, single, double, shadow
    border = "single",

    -- Bottom, top
    position = "bottom",

    -- Extra window margin [top, right, bottom, left]
    margin = { 1, 0, 1, 0 },

    -- Extra window padding [top, right, bottom, left]
    padding = { 2, 2, 2, 2 },

    winblend = 0
  },

  layout = {
    -- Min and max height of the columns
    height = { min = 4, max = 25 },

    -- Min and max width of the columns
    width = { min = 20, max = 50 },

    -- Spacing between columns
    spacing = 3,

    -- Align columns left, center or right
    align = "left",
  },

  -- Show help message on the command line when the popup is visible
  show_help = true,

  -- Show the currently pressed key and its label as a message in the command line
  show_keys = true,

  -- Disabled by default for Telescope
  disable = {
    buftypes = {},
    filetypes = { "TelescopePrompt" },
  },
})
