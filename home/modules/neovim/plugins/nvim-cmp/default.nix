{ pkgs, ... }:

{
  # Configure neovim
  programs.neovim = {

    # Install plugins related to cmp
    plugins = with pkgs.vimPlugins; [

      # Install nvim-cmp plugin
      {
        plugin = nvim-cmp;
        type = "lua";
        config = builtins.readFile ./config.lua;
      }

      # Install lsp integrations for cmp
      cmp-nvim-lsp

      # Install nvim-treesitter integrations for cmp
      cmp-treesitter
    ];
  };
}
