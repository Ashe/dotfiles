{ pkgs, ... }:

{
  # Configure neovim
  programs.neovim = {

    # Install which-key plugin
    plugins = with pkgs.vimPlugins; [ {
      plugin = which-key-nvim;
      config = ''
        " ================================
        " which-key
        " ================================

        set timeoutlen=500
        lua << EOF
          require('which-key').setup {
            -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
          }
        EOF

        " Background
        highlight WhichKeyFloat ctermbg=0

        " Label
        highlight WhichKeyDesc ctermfg=6

        " Separator
        highlight WhichKeySeparator ctermfg=4
      '';
    }];
  };
}
