----------------------------------
-- nvim-lspconfig
----------------------------------

-- Keybindings

-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap=true, silent=true }
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)

  -- Function that lets us more easily define mappings specific for LSP items
  -- It sets the mode, buffer and description for us each time
  local nmap = function(keys, func, desc)
    vim.keymap.set('n', keys, func, {
      noremap=true, silent=true, buffer = bufnr, desc = desc
    })
  end

  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- General mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  nmap('gD', vim.lsp.buf.declaration, 'Goto Declaration')
  nmap('gd', vim.lsp.buf.definition, 'Goto Definition')
  nmap('K', vim.lsp.buf.hover, 'Hover documentation')
  nmap('gi', vim.lsp.buf.implementation, 'Goto Implementation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  which_key.register({ c = { name = "Code.." } }, { prefix = "<leader>" })
  nmap('<leader>cs', vim.lsp.buf.signature_help, 'Signature Documentation')
  nmap('<leader>cr', vim.lsp.buf.rename, 'Rename symbol')
  nmap('<leader>cd', vim.lsp.buf.type_definition, 'Type Definition')
  nmap('<leader>ca', vim.lsp.buf.code_action, 'Code Action')
  nmap('<leader>cf', vim.lsp.buf.formatting, 'Format Code')

  -- Telescope mappings
  nmap('<leader>fr', require('telescope.builtin').lsp_references, 'References')
  nmap('<leader>fs', require('telescope.builtin').lsp_document_symbols, 'Document Symbols')
end


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
