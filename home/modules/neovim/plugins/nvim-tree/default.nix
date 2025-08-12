{ pkgs, ... }:

{
  # Configure neovim
  programs.neovim = {

    # Install plugins related to nvim-tree plugin
    plugins = with pkgs.vimPlugins; [

      # Install nvim-tree
      {
        plugin = nvim-tree-lua;
        type = "lua";
        config = builtins.readFile ./config.lua;
      }

      # Install devicons to improve appearance
      nvim-web-devicons
    ];
  };
}
