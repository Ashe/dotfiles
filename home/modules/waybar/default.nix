_: { config, lib, pkgs, ... }:

{
  # Add options for waybar, a bar utility for wayland
  options.waybar.enable = lib.mkEnableOption "waybar";

  # Install waybar if desired
  config = lib.mkIf config.waybar.enable (lib.mkMerge [

    # General waybar settings
    {
      # Enable waybar
      programs.waybar = {
        enable = true;
        style = ./style.css;
      };

      # Copy configurations
      xdg.configFile."waybar/configs".source = ./configs;
      xdg.configFile."waybar/modules.jsonc".source = ./modules.jsonc;

      # Copy scripts
      xdg.configFile."waybar/scripts".source = ./scripts;

      # Install extra programs for use with waybar
      home.packages = with pkgs; [

        # For controlling volume via pactl
        pulseaudio-ctl
      ];
    }

    # Start waybar with hyprland
    (lib.mkIf config.hyprland.enable {
      wayland.windowManager.hyprland.extraConfig = ''

        # Reload waybar
        exec = ~/.config/waybar/scripts/switch-waybar.sh
      '';
    })
  ]);
}
