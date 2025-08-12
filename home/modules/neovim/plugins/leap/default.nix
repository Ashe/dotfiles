{ pkgs, ... }:

{
  # Configure neovim
  programs.neovim = {

    # Install leap for nvim
    plugins = with pkgs.vimPlugins; [{
      plugin = leap-nvim;
      type = "lua";
      config = ''
        ----------------------------------
        -- leap
        ----------------------------------

        require('leap').add_default_mappings()
      '';
    }];
  };
}
