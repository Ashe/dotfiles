{ pkgs, ... }:

{
  # Configure neovim
  programs.neovim = {

    # Install dashboard for nvim
    plugins = with pkgs.vimPlugins; [{
      plugin = dashboard-nvim;
      config = (builtins.readFile ./config.vim);
    }];
  };
}
