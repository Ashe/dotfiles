local actions = require("diffview.actions")
local diffview_lib = require("diffview.lib")

require("diffview").setup({
	enhanced_diff_hl = true,
	hooks = {
		diff_buf_read = function()
			vim.opt_local.wrap = false
			vim.opt_local.colorcolumn = ""
		end,
	},
	keymaps = {
		view = {
			{ "n", "<leader>of", actions.focus_files, { desc = "Focus file tree" } },
		},
		file_panel = {
			{ "n", "<leader>of", actions.focus_files, { desc = "Focus file tree" } },
		},
	},
})

local function in_diffview()
	return diffview_lib.get_current_view() ~= nil
end

-- Default bindings put conflicts under <leader>c when in diffview
which_key_add({ { "<leader>c", group = "Conflicts..", cond = in_diffview } })

vim.keymap.set("n", "<leader>od", function()
	if in_diffview() then
		vim.cmd("DiffviewClose")
	else
		vim.cmd("DiffviewOpen")
	end
end, { desc = "Toggle diff view" })
