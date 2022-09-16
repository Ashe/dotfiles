{ pkgs, ... }:

{
  # Configure neovim
  programs.neovim = {

    # Install nvim-tree plugin
    plugins = with pkgs.vimPlugins; [ {
      plugin = nvim-tree-lua;
      config = (builtins.readFile ./config.vim);
    }];
  };
}
