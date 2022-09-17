" ================================
" nvim-treesitter
" ================================

lua << EOF

require'nvim-treesitter.configs'.setup {

  -- A list of parser names, or "all"
  ensure_installed = all,

  -- Automatically install missing parsers when entering buffer
  auto_install = true,

  -- Change install location for parsers
  parser_install_dir = "~/.local/share/nvim-treesitter/parsers",

  -- Enable syntax highlighting
  highlight = {
    enable = true,
  }
}

-- Ensure parser location added to path
vim.opt.runtimepath:append("~/.local/share/nvim-treesitter/parsers")

EOF
