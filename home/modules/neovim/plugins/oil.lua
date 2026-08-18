-- Binding for opening oil and opening oil submenu while inside
local oil_binding = "<leader>o"

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
which_key_add({ { oil_binding, group = "Oil.." } })

local oil_group = vim.api.nvim_create_augroup("UserOil", {})

-- Browse files without giving up the current window
local function set_browser_key()
	vim.keymap.set("n", oil_binding, function()
		if vim.bo.filetype == "oil" then
			return
		end
		require("oil").toggle_float()
	end, { desc = "Toggle file browser" })
end
set_browser_key()

-- Allow rebinding of oil keybinding while inside an oil buffer
vim.api.nvim_create_autocmd("BufEnter", {
	group = oil_group,
	pattern = "oil://*",
	callback = function()
		pcall(vim.keymap.del, "n", oil_binding)
	end,
})

-- Re-enable the keybinding to open oil after closing oil
vim.api.nvim_create_autocmd("BufLeave", {
	group = oil_group,
	pattern = "oil://*",
	callback = set_browser_key,
})

-- Oil-buffer specific keybindings
vim.api.nvim_create_autocmd("FileType", {
	group = oil_group,
	pattern = "oil",
	callback = function(ev)
		local oil = require("oil")
		local actions = require("oil.actions")

		-- Prefix bindings with the oil_binding
		local function map(suffix, rhs, desc)
			vim.keymap.set("n", oil_binding .. suffix, rhs, { buffer = ev.buf, desc = desc })
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
