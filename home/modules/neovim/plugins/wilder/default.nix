{ pkgs, ... }:

{
  programs.neovim.plugins = with pkgs.vimPlugins; [

    # Install wilder
    {
      plugin = wilder-nvim;
      type = "lua";
      config = builtins.readFile ./config.lua;
    }

    # Install devicons to improve appearance
    nvim-web-devicons
  ];
}
