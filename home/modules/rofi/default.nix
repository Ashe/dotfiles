{ config, lib, pkgs, ... }:

{
  # Add options for rofi application switcher
  options.rofi.enable = lib.mkEnableOption "rofi";

  # Install and configure rofi if desired
  config = lib.mkIf config.rofi.enable {

    # Enable rofi
    programs.rofi = {
      enable = true;
      package = pkgs.rofi-wayland-unwrapped;
    };

    # Configure rofi
    xdg.configFile."rofi/config.rasi".text = builtins.readFile ./config.rasi;
    xdg.configFile."rofi/extra-config.rasi".text = '''';

    # Copy scripts folder
    xdg.configFile."rofi/scripts".source = ./scripts;
  };
}
