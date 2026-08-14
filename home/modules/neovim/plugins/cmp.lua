local cmp = require("cmp")
local lspkind = require("lspkind")

cmp.setup({
	-- Buffer words are a fallback group, only queried when the sources
	-- above return no matches
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
		{ name = "path" },
	}, {
		{ name = "buffer" },
	}),
	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},
	formatting = {
		format = lspkind.cmp_format({
			maxwidth = 50,
		}),
	},
	mapping = cmp.mapping.preset.insert({
		["<C-b>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete(),
		["<C-e>"] = cmp.mapping.abort(),
		["<C-l>"] = cmp.mapping.confirm({ select = true }),
		["<CR>"] = cmp.mapping.confirm({ select = false }),
	}),
})

-- Completion for '/' search
cmp.setup.cmdline("/", {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{ name = "buffer" },
	},
})

-- Completion for ':' commands
cmp.setup.cmdline(":", {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{ name = "cmdline" },
		{ name = "path" },
	}),
})
