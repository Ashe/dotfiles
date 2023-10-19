_: { config, pkgs, lib, ... }:

{
  # Add options for sway-notification-center, a notification manager for wayland
  options.sway-notification-center.enable = lib.mkEnableOption "sway-notification-center";

  # Install sway-notification-center if desired
  config = lib.mkIf (config.sway.enable && config.sway-notification-center.enable) {

    # Install Sway Notification Center
    home.packages = [
      pkgs.swaynotificationcenter
    ];

    # Manage sway notification center settings
    xdg.configFile."swaync/config.json".source = ./config.json;
    xdg.configFile."swaync/style.css".source = ./style.css;
  };
}
