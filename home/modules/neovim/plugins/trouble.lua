require("trouble").setup({})

-- Specific trouble panels
require("which-key").add({ { "<leader>x", group = "Trouble.." } })
vim.keymap.set("n", "<leader>q", "<Cmd>Trouble diagnostics toggle<CR>", { desc = "Open diagnostics" })
vim.keymap.set("n", "<leader>xd", "<Cmd>Trouble diagnostics toggle<CR>", { desc = "Diagnostics" })
vim.keymap.set("n", "<leader>xb", "<Cmd>Trouble diagnostics toggle filter.buf=0<CR>", { desc = "Buffer diagnostics" })
vim.keymap.set("n", "<leader>xs", "<Cmd>Trouble symbols toggle<CR>", { desc = "Symbols" })
vim.keymap.set("n", "<leader>xr", "<Cmd>Trouble lsp_references toggle<CR>", { desc = "LSP references" })
