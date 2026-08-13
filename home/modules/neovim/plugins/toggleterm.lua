require("toggleterm").setup({
	size = 80,
	float_opts = { border = "curved" },
})

-- Change size and position based on window size
vim.keymap.set({ "n", "t" }, "<C-`>", function()
	local cols = vim.o.columns
	local direction, size
	if cols > 160 then
		direction, size = "vertical", 60
	elseif cols > 130 then
		direction, size = "vertical", 50
	elseif cols > 100 then
		direction, size = "vertical", 40
	else
		direction, size = "float", nil
	end

	if size then
		vim.cmd("ToggleTerm direction=" .. direction .. " size=" .. size)
	else
		vim.cmd("ToggleTerm direction=" .. direction)
	end
end, { desc = "Toggle terminal" })
