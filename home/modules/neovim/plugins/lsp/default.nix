{ pkgs, lib, ... }:

{
  programs.neovim.plugins = with pkgs.vimPlugins; [

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

  # Install language servers
  home.packages = with pkgs; [

    ####################
    # General servers  #
    ####################

    # C / C++
    ccls

    # CMake
    cmake-language-server

    # Nix
    nixd

  ] ++ lib.optionals pkgs.stdenv.isLinux [

    #########################
    # Linux-exclusive servers #
    #########################

    # GLSL
    glslls

  ];

  # Add language server specific files to global ignore list
  programs.git.ignores = [
    ".ccls-cache/"
  ];
}
