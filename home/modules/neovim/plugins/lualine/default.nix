{ pkgs, ... }:

{
  # Configure neovim
  programs.neovim = {

    # Install lualine
    plugins = with pkgs.vimPlugins; [{
      plugin = lualine-nvim;
      type = "lua";
      config = ''
        ----------------------------------
        -- lualine
        ----------------------------------

        require('lualine').setup({
          options = {
            theme = 'palenight'
          }
        })
      '';
    }];
  };
}
