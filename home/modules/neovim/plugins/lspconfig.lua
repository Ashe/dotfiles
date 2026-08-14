-- Disable default bindings
for _, lhs in ipairs({ "grn", "gra", "grr", "gri", "grt" }) do
	pcall(vim.keymap.del, "n", lhs)
end
pcall(vim.keymap.del, { "n", "x" }, "gO")
pcall(vim.keymap.del, "i", "<C-s>")

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		-- Enable completion triggered by <c-x><c-o>
		vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

		local inc_rename = try_require("inc_rename")
		local ts = try_require("telescope.builtin")
		local has_trouble = vim.fn.exists(":Trouble") == 2

		---------------
		-- Functions --
		---------------

		local function map(mode, lhs, rhs, desc)
			vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, desc = desc })
		end

		local function map_rename(lhs)
			if inc_rename then
				vim.keymap.set("n", lhs, function()
					return ":IncRename " .. vim.fn.expand("<cword>")
				end, { expr = true, buffer = ev.buf, desc = "Rename symbol" })
			else
				vim.keymap.set("n", lhs, vim.lsp.buf.rename, { buffer = ev.buf, desc = "Rename symbol" })
			end
		end

		local function code_action_kind(kind)
			return function()
				vim.lsp.buf.code_action({ context = { only = { kind } } })
			end
		end

		-- 'Lists' mappings
		local function references_list()
			if has_trouble then
				vim.cmd("Trouble lsp_references toggle focus=true")
			else
				vim.lsp.buf.references()
			end
		end

		local function lsp_list()
			if has_trouble then
				vim.cmd("Trouble lsp toggle focus=false win.position=right")
			else
				references_list()
			end
		end

		local function document_symbols_list()
			if has_trouble then
				vim.cmd("Trouble symbols toggle focus=false")
			else
				vim.lsp.buf.document_symbol()
			end
		end

		local function incoming_calls_list()
			if has_trouble then
				vim.cmd("Trouble lsp_incoming_calls toggle focus=true")
			else
				vim.lsp.buf.incoming_calls()
			end
		end

		local function outgoing_calls_list()
			if has_trouble then
				vim.cmd("Trouble lsp_outgoing_calls toggle focus=true")
			else
				vim.lsp.buf.outgoing_calls()
			end
		end

		local function diagnostics_list_buf()
			if has_trouble then
				vim.cmd("Trouble diagnostics toggle filter.buf=0")
			else
				vim.diagnostic.setloclist({ open = true })
			end
		end

		local function diagnostics_list_all()
			if has_trouble then
				vim.cmd("Trouble diagnostics toggle")
			else
				vim.diagnostic.setqflist({ open = true })
			end
		end

		-----------------
		-- Keybindings --
		-----------------

		-- Keybinding groups
		which_key_add({
			{ "<leader>c", group = "Code..", mode = { "n", "x" } },
			{ "<leader>cR", group = "Refactor..", mode = { "n", "x" } },
			{ "<leader>cl", group = "Lists.." },
			{ "<leader>cw", group = "Workspaces.." },
		})

		-- General shortcuts
		map("n", "gD", vim.lsp.buf.declaration, "Goto declaration")
		map("n", "gd", vim.lsp.buf.definition, "Goto definition")
		map("n", "gi", vim.lsp.buf.implementation, "Goto implementation")
		map("n", "K", vim.lsp.buf.hover, "Hover documentation")
		map("n", "<C-n>", ts and ts.lsp_dynamic_workspace_symbols or vim.lsp.buf.workspace_symbol, "All symbols")

		-- Code mappings
		map({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
		map({ "n", "x" }, "<leader>a", vim.lsp.buf.code_action, "Code action")
		map("n", "<leader>cc", "<Cmd>LspCheck<CR>", "Check file")
		map("n", "<leader>cs", vim.lsp.buf.signature_help, "Signature documentation")
		map("n", "<leader>cd", ts and ts.lsp_type_definitions or vim.lsp.buf.type_definition, "Type definitions")
		map_rename("<leader>cr")

		-- Refactor mappings
		map({ "n", "x" }, "<leader>cRe", code_action_kind("refactor.extract"), "Extract")
		map({ "n", "x" }, "<leader>cRi", code_action_kind("refactor.inline"), "Inline")
		map({ "n", "x" }, "<leader>cRw", code_action_kind("refactor.rewrite"), "Rewrite")
		map_rename("<leader>cRr")

		-- List mappings
		map("n", "<leader>cll", lsp_list, "Combined")
		map("n", "<leader>clr", references_list, "References")
		map("n", "<leader>cls", document_symbols_list, "Document symbols")
		map("n", "<leader>cli", incoming_calls_list, "Incoming calls")
		map("n", "<leader>clo", outgoing_calls_list, "Outgoing calls")
		map("n", "<leader>cld", diagnostics_list_buf, "Diagnostics (buffer)")
		map("n", "<leader>clD", diagnostics_list_all, "Diagnostics (workspace)")

		-- Code-workspace mappings
		map("n", "<leader>cwa", vim.lsp.buf.add_workspace_folder, "Add workspace folder")
		map("n", "<leader>cwr", vim.lsp.buf.remove_workspace_folder, "Remove workspace folder")
		map("n", "<leader>cwl", function()
			print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
		end, "List workspace folders")

		-- Find mappings
		map("n", "<leader>fr", ts and ts.lsp_references or vim.lsp.buf.references, "References")
		map("n", "<leader>fs", ts and ts.lsp_document_symbols or vim.lsp.buf.document_symbol, "Document symbols")
		map("n", "<leader>fS", ts and ts.lsp_dynamic_workspace_symbols or vim.lsp.buf.workspace_symbol, "All symbols")
		map("n", "<leader>ft", ts and ts.lsp_type_definitions or vim.lsp.buf.type_definition, "Type definitions")
		map("n", "<leader>fi", ts and ts.lsp_incoming_calls or vim.lsp.buf.incoming_calls, "Incoming calls")
		map("n", "<leader>fo", ts and ts.lsp_outgoing_calls or vim.lsp.buf.outgoing_calls, "Outgoing calls")
	end,
})

-- Servers

-- Set default capabilities for all LSP servers
local cmp_nvim_lsp = try_require("cmp_nvim_lsp")
vim.lsp.config("*", {
	capabilities = cmp_nvim_lsp and cmp_nvim_lsp.default_capabilities() or vim.lsp.protocol.make_client_capabilities(),
	flags = {
		debounce_text_changes = 150,
	},
})

-- Potential servers to look for
vim.lsp.enable({
	"ccls",
	"cmake",
	"dartls",
	"gdscript",
	"glslls",
	"gleam",
	"hls",
	"nixd",
	"rust_analyzer",
	"taplo",
	"lua_ls",
	"marksman",
})

-- Enavle specific language servers to run on the fly for specific files
local lsp_check = {
	rust_analyzer = function(client, bufnr)
		client:notify("rust-analyzer/runFlycheck", {
			textDocument = vim.lsp.util.make_text_document_params(bufnr),
		})
	end,
}

-- Command for triggering on-demand analysis if supported by the server
vim.api.nvim_create_user_command("LspCheck", function()
	local bufnr = vim.api.nvim_get_current_buf()
	local clients = vim.lsp.get_clients({ bufnr = bufnr })
	local checked = {}
	for _, client in ipairs(clients) do
		if lsp_check[client.name] then
			lsp_check[client.name](client, bufnr)
			table.insert(checked, client.name)
		end
	end
	if #checked > 0 then
		vim.notify("Re-checking via " .. table.concat(checked, ", "))
	elseif #clients == 0 then
		vim.notify("No language server attached", vim.log.levels.WARN)
	else
		vim.notify("Attached servers already re-check continuously")
	end
end, { desc = "Re-check the current file" })

-- Enable specific servers to get, select, and list compilation targets
local lsp_targets = {
	rust_analyzer = {
		get = function()
			return vim.tbl_get(vim.lsp.config["rust_analyzer"] or {}, "settings", "rust-analyzer", "cargo", "target")
		end,
		set = function(target)
			vim.lsp.config("rust_analyzer", {
				settings = { ["rust-analyzer"] = { cargo = { target = target } } },
			})
		end,
		list = function()
			local targets = vim.fn.systemlist("rustc --print target-list")
			return vim.v.shell_error == 0 and targets or {}
		end,
	},
}

-- Remember startup target per server so it can be restored by :LspTarget default
local lsp_target_defaults = {}

-- Change current target
local function lsp_target_set(name, target)
	local spec = lsp_targets[name]
	if lsp_target_defaults[name] == nil then
		lsp_target_defaults[name] = { spec.get() }
	end
	if target == "default" then
		target = lsp_target_defaults[name][1] or vim.NIL
	end
	spec.set(target)

	-- Re-enable LSP with the new target (restarting would revert target changes)
	vim.lsp.enable(name, false)
	vim.defer_fn(function()
		vim.lsp.enable(name)
	end, 500)

	local label = target == vim.NIL and "default" or target
	vim.notify(name .. " target: " .. label .. " (restarting)")
end

-- Command for changing target architecture on the fly
vim.api.nvim_create_user_command("LspTarget", function(cmd)
	-- Aim for the first attached server that supports target switching
	local name
	for candidate in pairs(lsp_targets) do
		if #vim.lsp.get_clients({ name = candidate }) > 0 then
			name = candidate
			break
		end
	end
	if not name then
		vim.notify("No attached server supports target switching", vim.log.levels.WARN)
		return
	end
	if cmd.args ~= "" then
		lsp_target_set(name, cmd.args)
		return
	end

	-- Without an argument, pick from the server's known targets
	local choices = { "default" }
	vim.list_extend(choices, lsp_targets[name].list())

	-- If no telescope, use default UI
	local pickers = try_require("telescope.pickers")
	if not pickers then
		vim.ui.select(choices, { prompt = "Target for " .. name }, function(choice)
			if choice then
				lsp_target_set(name, choice)
			end
		end)
		return
	end

	-- Otherwise, use the dropdown theme from telescope
	local finders = require("telescope.finders")
	local tele_config = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")
	pickers
		.new(require("telescope.themes").get_dropdown(), {
			prompt_title = "Target for " .. name,
			finder = finders.new_table({ results = choices }),
			sorter = tele_config.generic_sorter({}),
			attach_mappings = function(prompt_bufnr)
				actions.select_default:replace(function()
					local entry = action_state.get_selected_entry()
					actions.close(prompt_bufnr)
					if entry then
						lsp_target_set(name, entry.value)
					end
				end)
				return true
			end,
		})
		:find()
end, {
	desc = "Switch language server compilation target",
	nargs = "?",
	complete = function(arglead)
		local items = { "default" }
		for _, spec in pairs(lsp_targets) do
			vim.list_extend(items, spec.list())
		end
		return vim.tbl_filter(function(item)
			return vim.startswith(item, arglead)
		end, items)
	end,
})
