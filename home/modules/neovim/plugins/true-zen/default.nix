{ pkgs, ... }:

{
  programs.neovim.plugins = with pkgs.vimPlugins; [{
    plugin = true-zen-nvim;
    type = "lua";
    config = builtins.readFile ./config.lua;
  }];
}
