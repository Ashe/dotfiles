{ pkgs, ... }:

{
  # Configure neovim
  programs.neovim = {

    # Install tokyo-night theme
    plugins = with pkgs.vimPlugins; [{
      plugin = tokyonight-nvim;
      config = ''
        colorscheme tokyonight-night
      '';
    }];
  };
}
