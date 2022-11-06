{ pkgs, ... }:

{
  # Configure neovim
  programs.neovim = {

    # Install gitsigns
    plugins = with pkgs.vimPlugins; [{
      plugin = gitsigns-nvim;
      config = (builtins.readFile ./config.vim);
    }];
  };
}
