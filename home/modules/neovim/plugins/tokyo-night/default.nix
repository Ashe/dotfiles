{ pkgs, ... }:

{
  programs.neovim.plugins = with pkgs.vimPlugins; [{
    plugin = tokyonight-nvim;
    type = "viml";
    config = ''
      colorscheme tokyonight-night
    '';
  }];
}
