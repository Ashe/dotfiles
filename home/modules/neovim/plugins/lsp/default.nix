{ pkgs, ... }:

{
  # Configure neovim
  programs.neovim = {

    # Install plugins related to lsp
    plugins = with pkgs.vimPlugins; [

      # Install nvim-lspconfig plugin
      {
        plugin = nvim-lspconfig;
        config = (builtins.readFile ./config.vim);
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
