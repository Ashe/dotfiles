{ pkgs, ... }:

{
  # Configure neovim
  programs.neovim = {

    # Install plugins related to plenary
    plugins = with pkgs.vimPlugins; [{
      plugin = plenary-nvim;
      type = "lua";
      config = ''
        ----------------------------------
        -- plenary
        ----------------------------------

        require('plenary')
      '';
    }];
  };
}
