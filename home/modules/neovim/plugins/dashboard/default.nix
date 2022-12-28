{ pkgs, ... }:

{
  # Configure neovim
  programs.neovim = {

    # Install dashboard for nvim
    plugins = with pkgs.vimPlugins; [{
      plugin = dashboard-nvim;
      type = "lua";
      config = builtins.readFile ./config.lua;
    }];
  };
}
