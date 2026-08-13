-- Disable default bindings
vim.g.lsp_no_default_keymaps = true
for _, lhs in ipairs({ "grn", "gra", "grr", "gri", "gro", "grt", "grx" }) do
	pcall(vim.keymap.del, "n", lhs)
end
pcall(vim.keymap.del, { "n", "x" }, "gO")

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
		map("n", "<leader>D", ts and ts.lsp_type_definitions or vim.lsp.buf.type_definition, "Type definitions")

		-- Code mappings
		map({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
		map({ "n", "x" }, "<leader>a", vim.lsp.buf.code_action, "Code action")
		map("n", "<leader>cs", vim.lsp.buf.signature_help, "Signature documentation")
		map("n", "<leader>cd", ts and ts.lsp_type_definitions or vim.lsp.buf.type_definition, "Type definitions")
		map_rename("<leader>cr")

		-- Refactor mappings
		map({ "n", "x" }, "<leader>cRe", code_action_kind("refactor.extract"), "Extract")
		map({ "n", "x" }, "<leader>cRi", code_action_kind("refactor.inline"), "Inline")
		map({ "n", "x" }, "<leader>cRw", code_action_kind("refactor.rewrite"), "Rewrite")
		map_rename("<leader>cRr")

		-- List mappings
		map("n", "<leader>cll", lsp_list, "LSP (defs/refs/… live)")
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
