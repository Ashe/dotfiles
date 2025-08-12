{ pkgs, ... }:

{
  # Configure neovim
  programs.neovim = {

    # Install nvim-surround
    plugins = with pkgs.vimPlugins; [{
      plugin = nvim-surround;
      type = "lua";
      config = builtins.readFile ./config.lua;
    }];
  };
}
