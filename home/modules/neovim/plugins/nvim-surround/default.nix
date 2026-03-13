{ pkgs, ... }:

{
  programs.neovim.plugins = with pkgs.vimPlugins; [{
    plugin = nvim-surround;
    type = "lua";
    config = builtins.readFile ./config.lua;
  }];
}
