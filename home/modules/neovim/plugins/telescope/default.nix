{ pkgs, ... }:

{
  # Configure neovim
  programs.neovim = {

    # Install plugins related to telescope
    plugins = with pkgs.vimPlugins; [

      # Install telescope
      {
        plugin = telescope-nvim;
        type = "lua";
        config = builtins.readFile ./config.lua;
      }

      # Install devicons to improve appearance
      nvim-web-devicons
    ];
  };

  # RipGrep used for telescope
  home.packages = with pkgs; [
    ripgrep
  ];
}
