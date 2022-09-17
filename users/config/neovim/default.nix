{ pkgs, ... }:

{
  # Configure neovim
  programs.neovim = {
    enable = true;
    vimAlias = true;
    vimdiffAlias = true;
    withPython3 = true;

    # General configuration for neovim
    extraConfig = (builtins.readFile ./config.vim);
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
  ];
}
