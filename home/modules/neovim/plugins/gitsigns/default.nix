{ pkgs, ... }:

{
  # Configure neovim
  programs.neovim = {

    # Install gitsigns
    plugins = with pkgs.vimPlugins; [{
      plugin = gitsigns-nvim;
      type = "lua";
      config = builtins.readFile ./config.lua;
    }];
  };
}
