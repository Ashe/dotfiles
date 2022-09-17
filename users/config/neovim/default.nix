{ pkgs, ... }:

{
  # Import plugins with customisation
  imports = [

    # Tabs
    ./plugins/barbar/default.nix

    # LSP configuring
    ./plugins/lsp/default.nix

    # Syntax highlighting
    ./plugins/nvim-treesitter/default.nix

    # Completion
    ./plugins/nvim-cmp/default.nix

    # File browsing
    ./plugins/nvim-tree/default.nix

    # File searching
    ./plugins/telescope/default.nix

    # Key suggestions
    ./plugins/which-key/default.nix
  ];

  # Configure neovim
  programs.neovim = {
    enable = true;
    vimAlias = true;
    vimdiffAlias = true;
    withPython3 = true;
    plugins = with pkgs.vimPlugins; [

      # Splash screen
      alpha-nvim

      # Status line
      galaxyline-nvim

      # Icons
      nvim-web-devicons

      # Whitespace trimming
      trim-nvim

      # Git representation
      gitsigns-nvim

      # Tmux integration
      vim-tmux-navigator

      # File detection
      rust-vim
      vim-nix
    ];

    # General configuration for neovim
    extraConfig = (builtins.readFile ./config.vim);
  };
}
