_: { config, lib, pkgs, theme, ... }:

{
  # Add options for vs-code, a text editor
  options.vs-code.enable = lib.mkEnableOption "vs-code";

  # Install vs-code if desired
  config = lib.mkIf config.vs-code.enable {

    # Configure Visual Studio Code
    programs.vscode = {

      # Enable VS Code
      enable = true;

      # Install extensions
      extensions = with pkgs.vscode-extensions; [

        # Theme
        theme.data.vs-code.package

        # Utility
        ms-vsliveshare.vsliveshare
        shardulm94.trailing-spaces
        vscodevim.vim
        xaver.clang-format

        # Languages
        bbenoist.nix
        haskell.haskell
        ms-vscode.cpptools
        ms-dotnettools.csharp
        yzhang.markdown-all-in-one
      ];

      # Set up user settings
      userSettings = {
        "workbench.colorTheme" = theme.data.vs-code.name;
        "workbench.startupEditor" = "none";
        "editor.fontFamily" = "'FiraCode Nerd Font', monospace";
        "window.zoomLevel" = 1;
        "editor.wordWrap" = "wordWrapColumn";
        "explorer.confirmDelete" = false;
        "git.confirmSync" = false;
        "window.menuBarVisibility" = "toggle";
        "editor.tabSize" = 2;
      };
    };
  };
}
