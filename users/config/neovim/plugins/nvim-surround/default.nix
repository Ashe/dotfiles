{ pkgs, ... }:

{
  # Configure neovim
  programs.neovim = {

    # Install nvim-surround
    plugins = with pkgs.vimPlugins; [{
      plugin = nvim-surround;
      config = ''
        " ================================
        " nvim-surround
        " ================================

        lua << EOF
        require("nvim-surround").setup({
          -- Configuration here, or leave empty to use defaults
        })
        EOF
      '';
    }];
  };
}
