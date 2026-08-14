-- Allow telescope to open searches in trouble if its loaded
local trouble_telescope = try_require("trouble.sources.telescope")
local open_with_trouble = trouble_telescope and trouble_telescope.open or nil

require("telescope").setup({
	pickers = {
		lsp_references = { theme = "dropdown" },
		lsp_document_symbols = { theme = "dropdown" },
		lsp_type_definitions = { theme = "cursor" },
	},
	defaults = {
		mappings = {
			i = {
				-- Send results to trouble
				["<C-t>"] = open_with_trouble,

				-- Preview window mappings for insert mode
				["<C-f>"] = false,
				["<C-u>"] = "preview_scrolling_up",
				["<C-d>"] = "preview_scrolling_down",
				["<C-k>"] = "preview_scrolling_up",
				["<C-j>"] = "preview_scrolling_down",
				["<C-h>"] = "preview_scrolling_left",
				["<C-l>"] = "preview_scrolling_right",
			},
			n = {
				-- Send results to trouble
				["<C-t>"] = open_with_trouble,

				-- Preview window mappings for normal mode
				["<C-f>"] = false,
				["<C-u>"] = "preview_scrolling_up",
				["<C-d>"] = "preview_scrolling_down",
				["<C-k>"] = "preview_scrolling_up",
				["<C-j>"] = "preview_scrolling_down",
				["<C-h>"] = "preview_scrolling_left",
				["<C-l>"] = "preview_scrolling_right",
			},
		},
	},
	extensions = {
		["ui-select"] = {
			require("telescope.themes").get_cursor(),
		},
	},
})

-- Use telescope as picker
require("telescope").load_extension("ui-select")

-- Keybindings
local builtin = require("telescope.builtin")

-- git_files, but falls back to find_files if not in a git repo
local project_files = function()
	local opts = {}
	vim.fn.system("git rev-parse --is-inside-work-tree")
	if vim.v.shell_error == 0 then
		builtin.git_files(opts)
	else
		builtin.find_files(opts)
	end
end

-- Keybinding groups
which_key_add({
	{ "<leader>f", group = "Find.." },
	{ "<leader>fv", group = "Vim.." },
})

-- Quick shortcuts
vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "Search buffers" })
vim.keymap.set("n", "<C-p>", project_files, { desc = "Project files" })
vim.keymap.set("n", "<C-S-p>", builtin.builtin, { desc = "Telescope builtins" })

-- General builtins
vim.keymap.set("n", "<leader>fT", builtin.builtin, { desc = "Telescope builtins" })
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Files" })
vim.keymap.set("n", "<leader>fR", builtin.oldfiles, { desc = "Recent files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "Diagnostics" })
vim.keymap.set("n", "<leader>fG", builtin.registers, { desc = "Registers" })
vim.keymap.set("n", "<leader>fc", builtin.command_history, { desc = "Command history" })
vim.keymap.set("n", "<leader>f/", builtin.search_history, { desc = "Search history" })

-- Vim related builtins
vim.keymap.set("n", "<leader>fvc", builtin.commands, { desc = "Commands" })
vim.keymap.set("n", "<leader>fvk", builtin.keymaps, { desc = "Keymaps" })
vim.keymap.set("n", "<leader>fvo", builtin.vim_options, { desc = "Options" })
vim.keymap.set("n", "<leader>fvh", builtin.help_tags, { desc = "Help tags" })
