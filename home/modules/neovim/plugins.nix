{
  pkgs,
  ...
}:

# Plugins to enable in novim
with pkgs.vimPlugins;
{
  # Lua utilities
  plenary = {
    package = plenary-nvim;
    require = true;
  };

  # Tabs
  barbar = {
    package = barbar-nvim;
    extraPlugins = [
      nvim-web-devicons # Icons
    ];
  };

  # Language servers
  lspconfig = {
    package = nvim-lspconfig;
    extraPlugins = [
      inc-rename-nvim # Visual renaming
    ];
    extraPackages = with pkgs; [
      nixd # Nix language server
    ];
  };

  # Syntax highlighting
  treesitter = {
    package = nvim-treesitter.withAllGrammars;
    extraPackages = with pkgs; [
      tree-sitter # CLI
    ];
  };

  # Automatic formatting
  conform = {
    package = pkgs.vimPlugins.conform-nvim;
    extraPackages = with pkgs; [
      nixfmt # Nix
      clang-tools # Clang-format
      rustfmt # Rust
      fourmolu # Haskell
    ];
  };

  # Completion
  cmp = {
    package = nvim-cmp;
    extraPlugins = [
      cmp-nvim-lsp # LSP integration
      cmp-treesitter # Treesitter integration
      cmp-cmdline # Commands
      cmp-cmdline-history # History
      cmp-path # Paths
      cmp-buffer # Buffers
      lspkind-nvim # Icons
    ];
  };

  # Motion
  leap = {
    package = leap-nvim;
    extraPlugins = [
      vim-repeat
    ];
  };

  # Commenting
  comment.package = nvim-comment;

  # Surrounding
  surround.package = nvim-surround;

  # Whitespace trimming
  trim.package = trim-nvim;

  # File browsing
  tree = {
    package = nvim-tree-lua;
    extraPlugins = [
      nvim-web-devicons # Icons
    ];
  };

  # File search and navigation modal
  telescope = {
    package = telescope-nvim;
    extraPlugins = [
      nvim-web-devicons # Icons
    ];
    extraPackages = with pkgs; [
      ripgrep # Live grepping
      fd # File finding
    ];
  };

  # Git integration
  gitsigns.package = gitsigns-nvim;

  # Status line
  lualine = {
    package = lualine-nvim;
    extraConfig = ''
      require('lualine').setup({
        options = {
          theme = 'palenight'
        }
      })
    '';
    extraPlugins = [
      nvim-web-devicons # Icons
    ];
  };

  # Cursor line
  cursorline.package = nvim-cursorline;

  # Zen mode
  true-zen.package = true-zen-nvim;

  # UI overhall
  noice = {
    package = noice-nvim;
    extraPlugins = [
      nui-nvim # Dependency
      nvim-notify # Notifications
      nvim-cmp # Documentation
    ];
  };

  # Key suggestions
  which-key = {
    package = which-key-nvim;
    extraPlugins = [
      nvim-web-devicons # Icons
    ];
  };

  # Notifications
  notify = {
    package = nvim-notify;
    extraPlugins = [
      nvim-treesitter # Error styling
    ];
  };

  # Tokyo night theme
  tokyo-night = {
    package = tokyonight-nvim;
    extraConfig = ''
      vim.cmd('colorscheme tokyonight-night')
    '';
  };
}
