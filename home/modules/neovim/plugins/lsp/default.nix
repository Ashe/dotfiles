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
        config = builtins.replaceStrings
          [ "<omnisharp>" ]
          [ "${pkgs.omnisharp-roslyn}" ]
          (builtins.readFile ./config.lua);
      }
    ];
  };

  # Install language servers
  home.packages = with pkgs; [

    # C / C++
    ccls

    # C-sharp
    omnisharp-roslyn

    # CMake
    cmake-language-server

    # Java
    java-language-server

    # Nix
    rnix-lsp
  ];

  # Add language server specific files to global ignore list
  programs.git.ignores = [
    ".ccls-cache/"
  ];
}
