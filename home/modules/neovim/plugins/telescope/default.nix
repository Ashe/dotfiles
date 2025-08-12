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

  # Install packages relating to telescope
  home.packages = with pkgs; [

    # Used for live grepping
    ripgrep

    # Helps with searching for files
    fd
  ];
}
