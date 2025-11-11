{ config, lib, shared-lib, pkgs, ... }:

{
  # Add options for zed text editor
  options.zed.enable = lib.mkEnableOption "zed";

  # Install zed if desired
  config = lib.mkIf config.zed.enable {

    # Configure zed
    programs.zed-editor = {

      # Install zed
      enable = true;
      package = (config.lib.nixGL.wrap pkgs.zed-editor);
      userSettings = shared-lib.fromJsonFile ./settings.json;
      userKeymaps = shared-lib.fromJsonFile ./keymap.json;

      # Allow for mutable configurations
      mutableUserSettings = true;
      mutableUserKeymaps = true;
      mutableUserDebug = true;
      mutableUserTasks = true;

      # Auto-install extensions
      extensions = [

        # Themes
        "tokyo-night"

        # Language extensions
        "basher"
        "clojure"
        "gdscript"
        "haskell"
        "html"
        "latex"
        "lua"
        "make"
        "neocmake"
        "nix"
        "scss"
        "toml"
      ];
    };

    # Install zed-specific packages
    home.packages = with pkgs; [
      nerd-fonts.fira-code
    ];
  };
}
