{ pkgs, ... }:

{
  # Configure neovim
  programs.neovim = {

    # Install plugins related to lsp
    plugins = with pkgs.vimPlugins; [

      # Install nvim-lspconfig plugin
      {
        plugin = nvim-lspconfig;
        type = "lua";
        config = builtins.readFile ./config.lua;
      }
    ];
  };

  # Install language servers
  home.packages = with pkgs; [

    # C / C++
    ccls

    # Java
    java-language-server

    # Nix
    rnix-lsp
  ];
}
