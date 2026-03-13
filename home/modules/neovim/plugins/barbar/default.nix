{ pkgs, ... }:

{
  programs.neovim.plugins = with pkgs.vimPlugins; [ {
    plugin = barbar-nvim;
    type = "lua";
    config = builtins.readFile ./config.lua;
  }];
}
