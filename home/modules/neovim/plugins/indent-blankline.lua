-- Mix two 24 bit colours plus an alpha value
local function blend(fg, bg, alpha)
	local function channel(shift)
		local f = math.floor(fg / shift) % 256
		local b = math.floor(bg / shift) % 256
		return math.floor(b + (f - b) * alpha + 0.5)
	end
	return channel(65536) * 65536 + channel(256) * 256 + channel(1)
end

-- Tweak the current theme to make colours dimmer
local opacity = 0.5
local function dim_indent_guides()
	local whitespace = vim.api.nvim_get_hl(0, { name = "Whitespace", link = false })
	local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
	if not whitespace.fg or not normal.bg then
		return
	end

	local fg = blend(whitespace.fg, normal.bg, opacity)
	vim.api.nvim_set_hl(0, "IblIndent", { fg = fg })
	vim.api.nvim_set_hl(0, "IblWhitespace", { fg = fg })
end

require("ibl").setup({
	indent = {
		-- A one eighth block, rather than the default three eighths
		char = "▏",
	},
})

-- Apply recolour whenever colourscheme is applied
vim.api.nvim_create_autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup("UserIblColors", {}),
	callback = dim_indent_guides,
})
dim_indent_guides()
