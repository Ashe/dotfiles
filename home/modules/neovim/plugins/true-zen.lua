require("true-zen").setup({
	-- Conguration goes here, or leave blank
})

which_key_add({ { "<leader>z", group = "Zen mode..", mode = { "n", "v" } } })

vim.keymap.set({ "n", "v" }, "<leader>zn", ":'<,'>TZNarrow<CR>", { desc = "Narrow" })
vim.keymap.set("n", "<leader>zf", ":TZFocus<CR>", { desc = "Focus" })
vim.keymap.set("n", "<leader>zm", ":TZMinimalist<CR>", { desc = "Minimalist" })
vim.keymap.set("n", "<leader>za", ":TZAtaraxis<CR>", { desc = "Ataraxis" })
