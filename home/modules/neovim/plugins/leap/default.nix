{ pkgs, ... }:

{
  programs.neovim.plugins = with pkgs.vimPlugins; [{
    plugin = leap-nvim;
    type = "lua";
    config = builtins.readFile ./config.lua;
  }];
}
