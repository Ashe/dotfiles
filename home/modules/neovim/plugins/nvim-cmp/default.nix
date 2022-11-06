{ pkgs, ... }:

{
  # Configure neovim
  programs.neovim = {

    # Install plugins related to cmp
    plugins = with pkgs.vimPlugins; [ 

      # Install nvim-cmp plugin
      {
        plugin = nvim-cmp;
        config = (builtins.readFile ./config.vim);
      }

      # Install lsp integrations for cmp
      cmp-nvim-lsp

      # Install nvim-treesitter integrations for cmp
      cmp-treesitter
    ];
  };
}
