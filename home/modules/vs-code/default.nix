{ config, lib, pkgs, ... }:

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
    };

    # Add config file for VS Code
    xdg.configFile."Code/User/settings.json" = {
      text = ''
        {
          "editor.fontFamily": "'FiraCode Nerd Font', monospace",
          "editor.tabSize": 2,
          "editor.wordWrap": "wordWrapColumn",
          "explorer.confirmDelete": false,
          "git.confirmSync": false,
          "window.menuBarVisibility": "toggle",
          "window.zoomLevel": 1,
          "workbench.startupEditor": "none",
        }
      '';
    };
  };
}
