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
      shardulm94.trailing-spaces
      vscodevim.vim
      xaver.clang-format

      # Languages
      bbenoist.nix
      haskell.haskell
      yzhang.markdown-all-in-one
    ];

    # Set up user settings
    userSettings = {
      "workbench.colorTheme" = (theme.data pkgs).vs-code.name;
      "workbench.startupEditor" = "none";
      "editor.fontFamily" = "'Fira Code', monospace";
      "window.zoomLevel" = 1;
      "editor.wordWrap" = "wordWrapColumn";
      "explorer.confirmDelete" = false;
      "git.confirmSync" = false;
      "window.menuBarVisibility" = "toggle";
      "editor.tabSize" = 2;
    };
  };
}
