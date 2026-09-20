-- Prefix for opening full-view plugins and Oil actions
local open_prefix = "<leader>o"

-- Configure oil
require("oil").setup({
	view_options = {
		show_hidden = true,
	},
	columns = {
		"icon",
		"mtime",
	},
	preview_win = {
		win_options = {
			number = false,
			relativenumber = false,
			signcolumn = "no",
		},
	},
	float = {
		border = "rounded",
		preview_split = "right",
	},

	-- Disable default keymaps that shadow global inputs
	keymaps = {
		["<C-h>"] = false,
		["<C-l>"] = false,
		["<C-p>"] = false,
	},
})

-- Lsp diagnostics as virtual text at the end of each entry
require("oil-lsp-diagnostics").setup()

-- Keybinding groups

local oil_group = vim.api.nvim_create_augroup("UserOil", {})

-- Browse files without giving up the current window
vim.keymap.set("n", open_prefix .. "o", require("oil").toggle_float, { desc = "Oil" })

-- Oil-buffer specific keybindings
vim.api.nvim_create_autocmd("FileType", {
	group = oil_group,
	pattern = "oil",
	callback = function(ev)
		local oil = require("oil")
		local actions = require("oil.actions")

		-- Highlight that this Open menu also contains Oil-local actions
		which_key_add({ { open_prefix, group = "Oil + Open..", buffer = ev.buf } })

		-- Prefix bindings with the open group
		local function map(suffix, rhs, desc)
			vim.keymap.set("n", open_prefix .. suffix, rhs, { buffer = ev.buf, desc = desc })
		end

		map("x", actions.open_external.callback, "Open externally")
		map(".", oil.toggle_hidden, "Toggle hidden files")
		map("s", actions.change_sort.callback, "Change sort order")
		map("p", actions.preview.callback, "Toggle preview")
		map("r", actions.refresh.callback, "Refresh listing")
		map("y", actions.copy_entry_path.callback, "Copy filepath")
		map("Y", actions.copy_entry_filename.callback, "Copy filename")
		map("c", oil.close, "Close browser")
		map("?", actions.show_help.callback, "Show every oil keymap")
	end,
})
