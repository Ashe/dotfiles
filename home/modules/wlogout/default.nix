{ config, lib, pkgs, ... }:

{
  # Add options for wlogout menu
  options.wlogout.enable = lib.mkEnableOption "wlogout";

  # Install and configure wlogout if desired
  config = lib.mkIf config.wlogout.enable {

    # Configure wlogout
    programs.wlogout = {

      # Enable wlogout
      enable = true;

      # Add styling
      style = ./style.css;

      # Configuration
      layout = [
        {
          label = "lock";
          action = "swaylock";
          text = "Lock";
          keybind = "l";
        }
        {
          label = "logout";
          action = "hyprctl dispatch exit 0";
          text = "Logout";
          keybind = "e";
        }
        {
          label = "suspend";
          action = "systemctl suspend && swaylock";
          text = "Suspend";
          keybind = "u";
        }
        {
          label = "shutdown";
          action = "systemctl poweroff";
          text = "Shutdown";
          keybind = "s";
        }
        {
          label = "hibernate";
          action = "systemctl hibernate";
          text = "Hibernate";
          keybind = "h";
        }
        {
          label = "reboot";
          action = "systemctl reboot";
          text = "Reboot";
          keybind = "r";
        }
      ];
    };

    # Additional styling rofi
    xdg.configFile."wlogout/extra-style.css".text = '''';

    # Copy scripts and icons
    xdg.configFile."wlogout/scripts".source = ./scripts;
    xdg.configFile."wlogout/icons".source = ./icons;
  };
}
