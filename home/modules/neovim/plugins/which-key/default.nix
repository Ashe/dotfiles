{ pkgs, ... }:

{
  # Configure neovim
  programs.neovim = {

    # Install plugins related to which-key
    plugins = with pkgs.vimPlugins; [

      # Install which-key plugin
      {
        plugin = which-key-nvim;
        type = "lua";
        config = builtins.readFile ./config.lua;
      }

      # Install devicons to improve appearance
      nvim-web-devicons
    ];
  };
}
