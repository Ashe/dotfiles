{ pkgs, ... }:

{
  # Configure neovim
  programs.neovim = {

    # Install plugins related to nvim-treesitter
    plugins = with pkgs.vimPlugins; [

      # Install nvim-treesitter
      {
        plugin = (nvim-treesitter.withPlugins (_: pkgs.tree-sitter.allGrammars));
        type = "lua";
        config = builtins.readFile ./config.lua;
      }
    ];
  };
}
