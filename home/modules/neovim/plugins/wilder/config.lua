----------------------------------
-- wilder
----------------------------------

local wilder = require('wilder')
wilder.setup({
  modes = {":", "/", "?"},
  next_key = "<C-P>",
  previous_key = "<C-N>",
  accept_key = "<Tab>",
  reject_key = "<C-BS>",
})

-- Configure the popup menu
wilder.set_option('renderer', wilder.popupmenu_renderer(
  wilder.popupmenu_border_theme({
    highlighter = wilder.basic_highlighter(),
    left = {' ', wilder.popupmenu_devicons()},
    right = {' ', wilder.popupmenu_scrollbar()},
    min_width = '100%', -- minimum height of the popupmenu, can also be a number
    max_height = '20%', -- to set a fixed height, set max_height to the same value
    reverse = 1,        -- if 1, shows the candidates from bottom to top
  })
))
