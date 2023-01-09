{ pkgs, ... }:

{
  # Configure neovim
  programs.neovim = {

    # Install plugins related to treesitter
    plugins = with pkgs.vimPlugins; [

      # Install nvim-treesitter
      {
        plugin = nvim-treesitter;
        type = "lua";
        config = builtins.readFile ./config.lua;
      }

      # Install nvim-treesitter-textobjects
      {
        plugin = nvim-treesitter-textobjects;
        type = "lua";
      }
    ];
  };

  # Install packages related to nvim-treesitter
  home.packages = with pkgs; [

    # Install tree-sitter so that it connects with nvim plugin
    tree-sitter

    # Treesitter-nvim requires 'cc' executable
    gcc

    # Treesitter-nvim requires 'node' executable
    nodejs
  ];
}
