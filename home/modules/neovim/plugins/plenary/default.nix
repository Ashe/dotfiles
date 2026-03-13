{ pkgs, ... }:

{
  programs.neovim.plugins = with pkgs.vimPlugins; [{
    plugin = plenary-nvim;
    type = "lua";
    config = ''
      ----------------------------------
      -- plenary
      ----------------------------------

      require('plenary')
    '';
  }];
}
