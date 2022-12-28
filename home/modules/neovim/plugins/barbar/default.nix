{ pkgs, ... }:

{
  # Configure neovim
  programs.neovim = {

    # Install barbar plugin
    plugins = with pkgs.vimPlugins; [ {
      plugin = barbar-nvim;
      type = "lua";
      config = builtins.readFile ./config.lua;
    }];
  };
}
