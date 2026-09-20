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

-- Diffview links its compact file-panel labels to full diff highlights, which
-- can include distracting backgrounds. Use Neovim's semantic foreground
-- groups instead so the colours continue to follow the active colorscheme.
local function set_file_panel_highlights()
	local links = {
		DiffviewFilePanelInsertions = "Added",
		DiffviewFilePanelDeletions = "Removed",
		DiffviewStatusAdded = "Added",
		DiffviewStatusUntracked = "Added",
		DiffviewStatusModified = "Changed",
		DiffviewStatusRenamed = "Changed",
		DiffviewStatusCopied = "Changed",
		DiffviewStatusTypeChanged = "Changed",
		DiffviewStatusUnmerged = "Changed",
		DiffviewStatusUnknown = "Removed",
		DiffviewStatusDeleted = "Removed",
		DiffviewStatusBroken = "Removed",
	}

	for group, target in pairs(links) do
		vim.api.nvim_set_hl(0, group, { link = target })
	end
end

set_file_panel_highlights()
vim.api.nvim_create_autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup("UserDiffviewHighlights", { clear = true }),
	callback = set_file_panel_highlights,
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
