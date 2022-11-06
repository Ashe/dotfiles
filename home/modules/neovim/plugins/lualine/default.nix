{ pkgs, ... }:

{
  # Configure neovim
  programs.neovim = {

    # Install lualine
    plugins = with pkgs.vimPlugins; [{
      plugin = lualine-nvim;
      config = ''
        " ================================
        " lualine
        " ================================

        lua << EOF
        require('lualine').setup {
          options = {
            theme = 'palenight'
          }
        }
        EOF
      '';
    }];
  };
}
