{ pkgs, theme, ... }:

{
  # Configure Visual Studio Code
  programs.vscode = {

    # Enable VS Code
    enable = true;

    # Install extensions
    extensions = with pkgs.vscode-extensions; [

      # Theme
      (theme.data pkgs).vs-code.package

      # Utility
      ms-vsliveshare.vsliveshare
      vscodevim.vim
      xaver.clang-format

      # Languages
      bbenoist.nix
      shardulm94.trailing-spaces
      yzhang.markdown-all-in-one
    ];
  };
}
