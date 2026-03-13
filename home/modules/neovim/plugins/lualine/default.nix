{ pkgs, ... }:

{
  programs.neovim.plugins = with pkgs.vimPlugins; [{
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
}
