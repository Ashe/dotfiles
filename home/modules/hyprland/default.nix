inputs : { config, lib, pkgs, ... }:

{
  # Add options for hyprland, a wayland window manager
  options.hyprland.enable = lib.mkEnableOption "hyprland";

  # Enable hyprland if desired
  config = lib.mkIf config.hyprland.enable {

    # Place additional files in .config/hyprland/extra
    xdg.configFile.sway = {
      source = ./extra;
      target = "hyprland/extra";
    };

    # Enable and configure hyprland
    wayland.windowManager.hyprland = {
      enable = true;
      extraConfig = builtins.readFile ./hyprland.conf;
    };

    # Allow swaylock to lock computer
    swaylock.enable = true;

    # Extra wayland-specific home configuration
    home = {

      # Extra packages accompanying hyprland
      packages = with pkgs; [

        # Install grimshot for screenshotting with hyprland
        grim
        sway-contrib.grimshot

        # Enable explicit use of xwayland compatibility layer
        xwayland

        # Colour picker
        hyprpicker

        # Wallpaper setter
        swaybg
      ];

      # Specify desktop environment environment variables
      sessionVariables = {
        XDG_CURRENT_DESKTOP = "Hyprland";
        XDG_SESSION_DESKTOP = "Hyprland";
        XDG_SESSION_TYPE = "wayland";
      };
    };
  };
}
