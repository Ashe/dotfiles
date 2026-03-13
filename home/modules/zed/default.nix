{ config, lib, shared-lib, pkgs, ... }:

{
  options.zed.enable = lib.mkEnableOption "zed";

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
        "git-firefly"
        "haskell"
        "html"
        "latex"
        "lua"
        "make"
        "neocmake"
        "nix"
        "scss"
        "toml"
        "xml"
      ];
    };

    # Install zed-specific packages
    home.packages = with pkgs; [

      # Font used in config
      nerd-fonts.fira-code

      # Nix language server
      nil
    ];
  };
}
