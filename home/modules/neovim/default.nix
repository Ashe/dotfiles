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
    ./plugins/dashboard/default.nix

    # Tabs
    ./plugins/barbar/default.nix

    # LSP configuring
    ./plugins/lsp/default.nix

    # Syntax highlighting
    ./plugins/nvim-treesitter/default.nix

    # Completion
    ./plugins/nvim-cmp/default.nix

    # Motion
    ./plugins/leap/default.nix

    # Commenting
    ./plugins/nvim-comment/default.nix

    # Surrounding
    ./plugins/nvim-surround/default.nix

    # Whitespace trimming
    ./plugins/trim/default.nix

    # File browsing
    ./plugins/nvim-tree/default.nix

    # File searching
    ./plugins/telescope/default.nix

    # Key suggestions
    ./plugins/which-key/default.nix

    # Git integration
    ./plugins/gitsigns/default.nix

    # Status line
    ./plugins/lualine/default.nix

    # Cursor line
    ./plugins/cursorline/default.nix

    # Zen mode
    ./plugins/true-zen/default.nix
  ];
}
