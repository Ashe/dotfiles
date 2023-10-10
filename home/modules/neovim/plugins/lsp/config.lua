----------------------------------
-- nvim-lspconfig
----------------------------------

-- Keybindings

-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { noremap=true, silent=true, desc="Show errors" })
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { noremap=true, silent=true, desc="Go to previous diagnositic" })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { noremap=true, silent=true, desc="Go to next diagnostic" })
vim.keymap.set('n', '<leader>q', function () vim.diagnostic.setloclist({ open = false }); require('telescope.builtin').loclist() end, { noremap=true, silent=true, desc = 'Open error list' })

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)

    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions

    -- General shortcuts
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { buffer = ev.buf, desc = "Goto declaration" })
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = ev.buf, desc = "Goto definition" })
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = ev.buf, desc = "Hover documentation" })
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { buffer = ev.buf, desc = "Goto implementation" })
    vim.keymap.set('n', '<C-n>', require('telescope.builtin').lsp_dynamic_workspace_symbols, { buffer = ev.buf, desc = 'All symbols' })
    vim.keymap.set('n', '<leader>D', require('telescope.builtin').lsp_type_definitions, { buffer = ev.buf, desc = 'Type definitions' })

    -- 'Code' mappings
    require('which-key').register({ c = { name = "Code.." } }, { prefix = "<leader>" })
    vim.keymap.set('n', '<leader>cs', vim.lsp.buf.signature_help, { buffer = ev.buf, desc = 'Signature documentation' })
    vim.keymap.set('n', '<leader>cr', vim.lsp.buf.rename, { buffer = ev.buf, desc = 'Rename symbol' })
    vim.keymap.set('n', '<leader>cd', require('telescope.builtin').lsp_type_definitions, { buffer = ev.buf, desc = 'Type definitions' })
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { buffer = ev.buf, desc = 'Code action' })
    vim.keymap.set('n', '<leader>cf', function() vim.lsp.buf.format { async = true } end, { buffer = ev.buf, desc = 'Format code' })

    -- 'Code-workspace' mappings
    require('which-key').register({ w = { name = "Workspaces.." } }, { prefix = "<leader>c" })
    vim.keymap.set('n', '<leader>cwa', vim.lsp.buf.add_workspace_folder, { buffer = ev.buf, desc = "Add workspace folder" })
    vim.keymap.set('n', '<leader>cwr', vim.lsp.buf.remove_workspace_folder, { buffer = ev.buf, desc = "Remove workspace folder" })
    vim.keymap.set('n', '<leader>cwl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, { buffer = ev.buf, desc = "List workspace folders" })

    -- 'Find' mappings
    vim.keymap.set('n', '<leader>fr', require('telescope.builtin').lsp_references, { buffer = ev.buf, desc = 'References' })
    vim.keymap.set('n', '<leader>fs', require('telescope.builtin').lsp_document_symbols, { buffer = ev.buf, desc = 'Document symbols' })
    vim.keymap.set('n', '<leader>fS', require('telescope.builtin').lsp_dynamic_workspace_symbols, { buffer = ev.buf, desc = 'All symbols' })
    vim.keymap.set('n', '<leader>ft', require('telescope.builtin').lsp_type_definitions, { buffer = ev.buf, desc = 'Type definitions' })
  end,
})

-- Servers

-- Setup lspconfig
local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())
local lspconfig = require('lspconfig')
local lsp_flags = {
  -- This is the default in Nvim 0.7+
  debounce_text_changes = 150,
}
local servers = {

  -- C / C++
  'ccls',

  -- Cmake
  'cmake',

  -- GDScript
  'gdscript',

  -- GLSL
  'glslls',

  -- Haskell
  'hls',

  -- Nix
  'rnix',

  -- Rust
  'rust_analyzer',
}

-- Congigure all servers
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    flags = lsp_flags,
    on_attach = on_attach,
    capabilities = capabilities
  }
end

-- Bespoke configurations

-- Java
lspconfig.java_language_server.setup {
  cmd = {"java-language-server"}
}

-- C#
lspconfig.omnisharp.setup {
  cmd = { "dotnet", "<omnisharp>/lib/omnisharp-roslyn/OmniSharp.dll" },
  root_dir = lspconfig.util.root_pattern(".sln",".git",".csproj")
}
