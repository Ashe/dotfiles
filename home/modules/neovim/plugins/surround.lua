-- Disable all default keymaps
vim.g.nvim_surround_no_mappings = true

require("nvim-surround").setup()

-- Insert mode
vim.keymap.set("i", "<C-a>s", "<Plug>(nvim-surround-insert)", { desc = "Add a surrounding pair (insert mode)" })
vim.keymap.set(
	"i",
	"<C-a>S",
	"<Plug>(nvim-surround-insert-line)",
	{ desc = "Add a surrounding pair around line (insert mode)" }
)

-- Normal mode
vim.keymap.set("n", "<C-a>s", "<Plug>(nvim-surround-normal)", { desc = "Add a surrounding pair around a motion" })
vim.keymap.set(
	"n",
	"<C-a>ss",
	"<Plug>(nvim-surround-normal-cur)",
	{ desc = "Add a surrounding pair around current line" }
)
vim.keymap.set(
	"n",
	"<C-a>S",
	"<Plug>(nvim-surround-normal-line)",
	{ desc = "Add a surrounding pair around a motion (line)" }
)
vim.keymap.set(
	"n",
	"<C-a>SS",
	"<Plug>(nvim-surround-normal-cur-line)",
	{ desc = "Add a surrounding pair around current line (line)" }
)
vim.keymap.set("n", "<C-a>d", "<Plug>(nvim-surround-delete)", { desc = "Delete a surrounding pair" })
vim.keymap.set("n", "<C-a>c", "<Plug>(nvim-surround-change)", { desc = "Change a surrounding pair" })
vim.keymap.set("n", "<C-a>C", "<Plug>(nvim-surround-change-line)", { desc = "Change a surrounding pair (line)" })

-- Visual mode
vim.keymap.set(
	"x",
	"<C-a>s",
	"<Plug>(nvim-surround-visual)",
	{ desc = "Add a surrounding pair around a visual selection" }
)
vim.keymap.set(
	"x",
	"<C-a>S",
	"<Plug>(nvim-surround-visual-line)",
	{ desc = "Add a surrounding pair around a visual selection (line)" }
)

require("which-key").add({ { "<C-a>", group = "Surround.." } })
require("which-key").add({ { "<C-a>s", group = "Surround inline.." } })
require("which-key").add({ { "<C-a>S", group = "Surround around line.." } })
