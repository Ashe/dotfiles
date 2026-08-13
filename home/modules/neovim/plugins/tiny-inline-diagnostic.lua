require("tiny-inline-diagnostic").setup({
	preset = "modern",
})

-- Disable vim's virtual diagnostics
vim.diagnostic.config({ virtual_text = false })
