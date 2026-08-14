require("nvim-lightbulb").setup({
	autocmd = {
		enabled = true,
		updatetime = -1,
		events = { "CursorHold" },
	},
	sign = {
		enabled = false,
	},
	virtual_text = {
		enabled = true,
	},
})
