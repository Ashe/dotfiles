{ pkgs, ... }:

{
  programs.neovim.plugins = with pkgs.vimPlugins; [{
    plugin = fidget-nvim;
    type = "lua";
    config = ''
      ----------------------------------
      -- fidget
      ----------------------------------

      require('fidget').setup({})
    '';
  }];
}
