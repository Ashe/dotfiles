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

  -- Add operators that will trigger motion and text object completion
  -- to enable all native operators, set the preset / operators plugin above
  operators = {
  },
  key_labels = {
    -- override the label used to display some keys. It doesn't effect WK in any other way.
    -- For example:
    -- ["<space>"] = "SPC",
    -- ["<cr>"] = "RET",
    -- ["<tab>"] = "TAB",
  },

  icons = {

    -- Symbol used in the command line area that shows your active key combo
    breadcrumb = "»",

    -- Symbol used between a key and it's label
    separator = "➜",

    -- Symbol prepended to a group
    group = "+ ",
  },

  popup_mappings = {

    -- Binding to scroll down inside the popup
    scroll_down = '<c-d>',

    -- Binding to scroll up inside the popup
    scroll_up = '<c-u>',
  },

  window = {
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

  -- Enable this to hide mappings for which you didn't specify a label
  ignore_missing = false,

  -- Hide mapping boilerplate
  hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ "},

  -- Show help message on the command line when the popup is visible
  show_help = true,

  -- Show the currently pressed key and its label as a message in the command line
  show_keys = true,

  -- Automatically setup triggers
  triggers = "auto",

  -- -- or specify a list manually
  -- triggers = {"<leader>"}
  --
  triggers_blacklist = {

    -- List of mode / prefixes that should never be hooked by WhichKey
    -- this is mostly relevant for key maps that start with a native binding
    -- Most people should not need to change this
    i = { "j", "k" },
    v = { "j", "k" },
  },
  -- Disable the WhichKey popup for certain buf types and file types.


  -- Disabled by default for Telescope
  disable = {
    buftypes = {},
    filetypes = { "TelescopePrompt" },
  },
})
