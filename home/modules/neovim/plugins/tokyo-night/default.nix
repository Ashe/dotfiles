{ pkgs, ... }:

{
  programs.neovim.plugins = with pkgs.vimPlugins; [{
    plugin = tokyonight-nvim;
    config = ''
      colorscheme tokyonight-night
    '';
  }];
}
