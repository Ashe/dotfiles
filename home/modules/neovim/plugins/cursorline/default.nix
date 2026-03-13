{ pkgs, ... }:

{
  programs.neovim.plugins = with pkgs.vimPlugins; [{
    plugin = nvim-cursorline;
    type = "lua";
    config = ''
      ----------------------------------
      -- cursorline
      ----------------------------------

      require('nvim-cursorline').setup({
        cursorline = {
          enable = true,
          timeout = 0,
          number = true,
        },
        cursorword = {
          enable = true,
          min_length = 3,
          hl = { underline = true },
        }
      })
    '';
  }];
}
