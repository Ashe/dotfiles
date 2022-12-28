{ pkgs, ... }:

{
  # Configure neovim
  programs.neovim = {

    # Install nvim-surround
    plugins = with pkgs.vimPlugins; [{
      plugin = nvim-surround;
      type = "lua";
      config = ''
        ----------------------------------
        -- nvim-surround
        ----------------------------------

        require('nvim-surround').setup({
          -- Configuration here, or leave empty to use defaults
        })
      '';
    }];
  };
}
