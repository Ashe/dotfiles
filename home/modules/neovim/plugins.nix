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

  # Terminal
  toggleterm.package = toggleterm-nvim;

  # Visual renaming (used by lspconfig)
  inc-rename = {
    package = inc-rename-nvim;
    extraConfig = ''
      require('inc_rename').setup({})
    '';
  };

  # Language servers
  lspconfig = {
    package = nvim-lspconfig;
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
      stylua # Lua
      yq-go # yaml, json, toml, xml
    ];
  };

  # Completion
  cmp = {
    package = nvim-cmp;
    extraPlugins = [
      cmp-nvim-lsp # LSP integration
      cmp-treesitter # Treesitter integration
      cmp-cmdline # Commands
      cmp-path # Filepaths
      cmp-buffer # Buffers
      lspkind-nvim # Icons
    ];
  };

  # Diagnostic viewer
  trouble = {
    package = trouble-nvim;
    extraConfig = ''
      require("trouble").setup({})
    '';
  };

  # Inline diagnostics
  tiny-inline-diagnostic.package = tiny-inline-diagnostic-nvim;

  # lightbulb
  lightbulb.package = nvim-lightbulb;

  # Leap motions
  leap = {
    package = leap-nvim;
    extraPlugins = [
      vim-repeat
    ];
  };

  # Jumping
  jumppack = {
    package = pkgs.vimUtils.buildVimPlugin {
      pname = "Jumppack.nvim";
      version = "unstable";
      src = pkgs.fetchFromGitHub {
        owner = "suliatis";
        repo = "Jumppack.nvim";
        rev = "c1bc410ef011afbd405e945a08ce200d59a0e537";
        hash = "sha256-7QR/9dRWnnOhrR6150LuIuc4HTb2Yi8qziFu/aCHJ0E=";
      };
    };
    extraConfig = ''
      require('Jumppack').setup()
    '';
  };

  # Commenting
  comment.package = nvim-comment;

  # Surrounding
  surround.package = nvim-surround;

  # Whitespace trimming
  trim.package = trim-nvim;

  # File tree
  tree = {
    package = nvim-tree-lua;
    extraPlugins = [
      nvim-web-devicons # Icons
    ];
  };

  # File management
  oil = {
    package = oil-nvim;
    extraPlugins = [
      oil-git-nvim
      oil-git-status-nvim
      oil-lsp-diagnostics-nvim
    ];
    extraConfig = ''
      require('oil').setup()
    '';
  };

  # File search and navigation modal
  telescope = {
    package = telescope-nvim;
    extraPlugins = [
      nvim-web-devicons # Icons
      telescope-ui-select-nvim # Select ui
    ];
    dependsOn = [
      "trouble" # Used as its display window
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
    ];
    dependsOn = [
      "notify" # Used for notification backend
      "cmp" # Used for cmdline/documentation rendering
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
    dependsOn = [
      "treesitter" # Used for error message styling
    ];
  };

  # Tokyo night theme
  tokyo-night = {
    package = tokyonight-nvim;
    extraConfig = ''
      vim.cmd.colorscheme('tokyonight-night')
    '';
  };
}
