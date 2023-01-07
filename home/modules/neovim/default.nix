_: { config, lib, pkgs, theme, ... }:

{
  # Add options for neovim text editor
  options.neovim.enable = lib.mkEnableOption "neovim";

  # Install neovim if desired
  config = lib.mkIf config.neovim.enable {

    # Configure neovim
    programs.neovim = {
      enable = true;
      vimAlias = true;
      vimdiffAlias = true;
      withPython3 = true;

      # General configuration for neovim
      extraConfig = builtins.replaceStrings
          ["<COLOURSCHEME>"] [theme.data.neovim.name]
          (builtins.readFile ./config.vim);

      # Install colourscheme
      plugins = [
        theme.data.neovim.package
      ];
    };
  };

  # Import plugins with customisation
  imports = [

    # Dashboard splash screen
    ./plugins/dashboard

    # Tabs
    ./plugins/barbar

    # LSP configuring
    ./plugins/lsp

    # Syntax highlighting
    ./plugins/nvim-treesitter

    # Completion
    ./plugins/nvim-cmp

    # Motion
    ./plugins/leap

    # Commenting
    ./plugins/nvim-comment

    # Surrounding
    ./plugins/nvim-surround

    # Whitespace trimming
    ./plugins/trim

    # File browsing
    ./plugins/nvim-tree

    # File searching
    ./plugins/telescope

    # Git integration
    ./plugins/gitsigns

    # Status line
    ./plugins/lualine

    # Cursor line
    ./plugins/cursorline

    # Progress visualisation
    ./plugins/fidget

    # Zen mode
    ./plugins/true-zen

    # Suggestions and completions for wildmenu
    ./plugins/wilder

    # Key suggestions
    ./plugins/which-key
  ];
}
