vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("UserTreesitterHighlight", {}),
	callback = function(ev)
		-- Fails quietly for filetypes without a parser
		pcall(vim.treesitter.start, ev.buf)
	end,
})
