{ inputs, config, lib, pkgs, ... }:

{
  # Add options for hyprland, a wayland window manager
  options.hyprland.enable = lib.mkEnableOption "hyprland";

  # Enable hyprland if desired
  config = lib.mkIf config.hyprland.enable {

    # Enable the hyprland module
    # The NixOS module enables critical components needed to run Hyprland properly, such as:
    # - polkit
    # - xdg-desktop-portal-hyprland
    # - graphics drivers
    # - fonts
    # - dconf
    # - xwayland
    # and adding a proper Desktop Entry to your Display Manager
    programs.hyprland = {
      enable = true;
      portalPackage = inputs.hyprland-portal.packages."x86_64-linux".xdg-desktop-portal-hyprland;
    };
  };
}
