{ pkgs, ... }:

{
  # Configure neovim
  programs.neovim = {

    # Install true-zen
    plugins = with pkgs.vimPlugins; [{
      plugin = true-zen-nvim;
      type = "lua";
      config = builtins.readFile ./config.lua;
    }];
  };
}
