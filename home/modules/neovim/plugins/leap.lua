local leap = require("leap")

-- Forward leap
vim.keymap.set({ "n", "x", "o" }, "s", function()
	leap.leap({ offset = 1 })
end, { desc = "Leap forward" })

-- Backward leap
vim.keymap.set({ "n", "x", "o" }, "S", function()
	leap.leap({ backward = true })
end, { desc = "Leap backward" })

-- Cross-window leap
vim.keymap.set({ "n", "x", "o" }, "gs", function()
	leap.leap({
		target_windows = vim.tbl_filter(function(win)
			return vim.api.nvim_win_get_config(win).focusable
		end, vim.api.nvim_tabpage_list_wins(0)),
	})
end, { desc = "Leap across all windows" })
