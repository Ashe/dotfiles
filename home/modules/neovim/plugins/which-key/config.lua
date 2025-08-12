----------------------------------
-- which-key
----------------------------------

require('which-key').setup({

  -- Configure which-key options
  opts = {

    -- Configure when to show which-key
    triggers = {
      { "<auto>", mode = "nixsotc" },
      { "<leader>", mode = { "n", "v" }},
    },
  },

  plugins = {

    -- Shows a list of your marks on ' and `
    marks = true,

    -- Shows your registers on " in NORMAL or <C-r> in INSERT mode
    registers = true,

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

  -- Configure which-key icons
  icons = {

    -- Symbol used in the command line area that shows your active key combo
    breadcrumb = "»",

    -- Symbol used between a key and it's label
    separator = "➜",

    -- Symbol prepended to a group
    group = "+ ",
  },

  win = {
    border = "single",
  },

  -- Configure the which-key window layout
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

  -- Prevent visual mode mappings
  defer = function(ctx)
    return ctx.mode == "v" or ctx.mode == "V" or ctx.mode == "<C-V>"
  end,
})
