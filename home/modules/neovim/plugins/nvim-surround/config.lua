----------------------------------
-- nvim-surround
----------------------------------

require('nvim-surround').setup({
  keymaps = {
    insert = "<C-a>s",
    insert_line = "<C-a>S",
    normal = "<C-a>s",
    normal_cur = "<C-a>ss",
    normal_line = "<C-a>S",
    normal_cur_line = "<C-a>SS",
    visual = "<C-a>s",
    visual_line = "<C-a>S",
    delete = "<C-a>d",
    change = "<C-a>c",
    change_line = "<C-a>C",
  },
})

require('which-key').add({{ "<C-a>", group = "Surround.." }})
require('which-key').add({{ "<C-a>s", group = "Surround inline.." }})
require('which-key').add({{ "<C-a>S", group = "Surround around line.." }})
