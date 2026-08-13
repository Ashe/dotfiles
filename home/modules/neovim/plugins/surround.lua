require("nvim-surround").setup()

-- Disable all default surround keymaps
vim.g.nvim_surround_no_mappings = true

-- General bindings
local surround_maps = {
	-- Insert mode
	{ "i", "s", "<Plug>(nvim-surround-insert)", "Surround motion" },
	{ "i", "S", "<Plug>(nvim-surround-insert-line)", "Surround motion on newlines" },

	-- Normal mode
	{ "n", "s", "<Plug>(nvim-surround-normal)", "Surround motion" },
	{ "n", "S", "<Plug>(nvim-surround-normal-line)", "Surround motion on newlines" },
	{ "n", "d", "<Plug>(nvim-surround-delete)", "Delete chosen surround" },
	{ "n", "c", "<Plug>(nvim-surround-change)", "Change chosen surround" },
	{ "n", "C", "<Plug>(nvim-surround-change-line)", "Change and newline chosen surround" },

	-- Visual mode
	{ "x", "s", "<Plug>(nvim-surround-visual)", "Surround selection" },
	{ "x", "S", "<Plug>(nvim-surround-visual-line)", "Surround selection on newlines" },
}

-- Expose all above bindings under both <C-a> and <leader>s
local prefixes = { "<C-a>", "<leader>s" }

-- Implement bindings
for _, map in ipairs(surround_maps) do
	local mode, suffix, rhs, desc = map[1], map[2], map[3], map[4]
	for _, prefix in ipairs(prefixes) do
		vim.keymap.set(mode, prefix .. suffix, rhs, { desc = desc })
	end
end

-- Keybinding groups
which_key_add({
	{ "<C-a>", group = "Surround.." },
	{ "<leader>s", group = "Surround.." },
})
