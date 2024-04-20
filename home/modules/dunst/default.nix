{ config, lib, pkgs, ... }:

{
  # Add options for dunst notification system
  options.dunst.enable = lib.mkEnableOption "dunst";

  # Install dunst if desired
  config = lib.mkIf config.dunst.enable (lib.mkMerge [

    # General dunst config
    {
      # Enable dunst notification daemon
      services.dunst.enable = true;

      # Configure dunst
      xdg.configFile."dunst/dunstrc".source = ./dunstrc;

      # Copy scripts
      xdg.configFile."dunst/scripts".source = ./scripts;

      # Install dunst-specific packages
      home.packages = with pkgs; [

        # Mononoki font
        mononoki

        # Allows for xdg-open
        xdg-utils
      ];
    }

    # Start dunst with hyprland
    (lib.mkIf config.hyprland.enable {
      wayland.windowManager.hyprland.extraConfig = ''
        # Reload dunst
        exec = ~/.config/dunst/scripts/start-dunst.sh
      '';
    })
  ]);
}
