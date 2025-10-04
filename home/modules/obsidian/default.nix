{ config, lib, pkgs, ... }:

{
  # Add options for obsidian note taking software
  options.obsidian.enable = lib.mkEnableOption "obsidian";

  # Install obsidian if desired
  config = lib.mkIf config.obsidian.enable {

    # Configure obsidian
    programs.obsidian = {
      enable = true;
      package = (config.lib.nixGL.wrap pkgs.obsidian);
      defaultSettings = {

        # Application settings
        app = {
          vimMode = true;
          trashOption = "local";
          promptDelete = false;
        };

        # Colour scheme
        appearance = {
          cssTheme = "Tokyo Night";
        };

        # Keybindings
        hotkeys = {
          "editor:insert-link" = [];
          "command-palette:open" = [{
            key = "K";
            modifiers = [
              "Mod"
            ];
          }];
          "switcher:open" = [{
            key = "P";
            modifiers = [
              "Mod"
            ];
          }];
          "app:toggle-left-sidebar" = [{
            key = "O";
            modifiers = [
              "Mod"
            ];
          }];
          "app:toggle-right-sidebar" = [{
            key = "O";
            modifiers = [
              "Mod"
              "Shift"
            ];
          }];
        };
      };

      # Template vault with default configuration to be copied from
      vaults.template = {
        enable = true;
        target = ".config/obsidian-vault-config";
      };

    };

    # Disable default obsidian.json file so that new vaults can be created
    xdg.configFile."obsidian/obsidian.json".enable = false;

  };
}
