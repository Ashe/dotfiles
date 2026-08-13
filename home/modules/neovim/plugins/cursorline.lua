require("nvim-cursorline").setup({
	cursorline = {
		enable = true,
		timeout = 0,
		number = true,
	},
	cursorword = {
		enable = true,
		min_length = 3,
		hl = { underline = true },
	},
	disable_filetypes = {
		"oil",
		"harpoon",
		"NvimTree",
		"neo-tree",
		"TelescopePrompt",
	},
	disable_buftypes = {
		"nofile",
		"terminal",
		"prompt",
		"acwrite",
	},
})
