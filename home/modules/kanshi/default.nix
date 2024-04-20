{ config, lib, pkgs, ... }:

{
  # Add options for kanshi, a service for managing monitors
  options.kanshi.enable = lib.mkEnableOption "kanshi";

  # Enable kanshi if desired
  config = lib.mkIf config.kanshi.enable (lib.mkMerge [

    {
      # Install kanshi as a package
      home.packages = with pkgs; [
        kanshi
      ];

      # Enable and configure kanshi
      services.kanshi = {
        enable = true;
        profiles = { };
      };
    }

    #
    (lib.mkIf config.hyprland.enable {
      wayland.windowManager.hyprland.extraConfig = ''
        # Reload kanshi
        exec = kanshi
      '';
    })

  ]);
}
