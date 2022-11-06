{ pkgs, ... }:

{
  # Configure neovim
  programs.neovim = {

    # Install plugins related to nvim-tree plugin
    plugins = with pkgs.vimPlugins; [

      # Install nvim-tree
      {
        plugin = nvim-tree-lua;
        config = (builtins.readFile ./config.vim);
      }

      # Install devicons to improve appearance
      nvim-web-devicons
    ];
  };
}
