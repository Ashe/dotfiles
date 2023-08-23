_: { config, lib, pkgs, theme, ... }:

{
  # Add options for waybar, a bar utility for wayland
  options.waybar.enable = lib.mkEnableOption "waybar";

  # Install waybar if desired
  config = lib.mkIf config.waybar.enable {

    # Place additional files in .config/waybar/extra
    xdg.configFile.waybar = {
      source = ./extra;
      target = "waybar/extra";
    };

    # Install extra programs for use with waybar
    home.packages = with pkgs; [

      # For controlling spotify etc
      playerctl

      # For controlling volume via pactl
      pulseaudio-ctl
    ];

    # Configure waybar
    programs.waybar = {

      # Install waybar
      enable = true;

      # Enable experimental features
      package = pkgs.waybar-hyprland;

      # Configure Waybar
      settings = [{

        # Basics
        layer = "top";
        position = "right";
        height = 200;
        margin-right = 10;

        # Center modules
        modules-center = [
          "custom/home"
          "wlr/workspaces"
          "wlr/taskbar"
          "custom/spotify"
          "tray"
          "network"
          "pulseaudio#icon"
          "pulseaudio#percentage"
          "battery#icon"
          "battery#percentage"
          "clock#calendar-icon"
          "clock#day"
          "clock#date"
          "clock#time-icon"
          "clock#time"
        ];

        # Home module
        "custom/home" = {
          format = "";
          on-click = "$MENU";
          on-click-right = "wlogout";
          on-scroll-up = "hyprctl dispatch workspace e-1";
          on-scroll-down = "hyprctl dispatch workspace e+1";
          tooltip = false;
        };

        # Workspace module
        "wlr/workspaces" = {
          format = "{icon}";
          format-icons = {
            default = "";
            urgent = "";
            active = "";
          };
          sort-by-number = true;
          on-click = "activate";
          on-scroll-up = "hyprctl dispatch workspace e-1";
          on-scroll-down = "hyprctl dispatch workspace e+1";
          on-click-backward = "hyprctl dispatch workspace e-1";
          on-click-forward = "hyprctl dispatch workspace e+1";
          tooltip = "AA";
        };

        # Taskbar module
        "wlr/taskbar" = {
          on-click = "minimize-raise";
          on-click-middle = "close";
          tooltip-format = "{title}";
        };

        # Spotify module
        "custom/spotify" = {
          format = "";
          interval = 1;
          exec-if = "pgrep spotify";
          return-type = "json";
          on-click = "playerctl -p spotify play-pause";
          on-scroll-up = "playerctl -p spotify previous";
          on-scroll-down = "playerctl -p spotify next";
          tooltip = true;
          escape = true;
          exec = "/home/ashe/.config/waybar/extra/spotify.sh"; #@TODO: ADD THIS SCRIPT
        };

        # Tray module
        tray = {
          icon-size = 18;
          spacing = 10;
        };

        # Network module
        network = {
          format-wifi = "";
          format-ethernet = "󰈀";
          format-linked = "󰈁";
          format-disconnected = "󰈂";
          tooltip-format-ethernet = "󰈀 {ifname}";
          tooltip-format-wifi = " {essid} ({signalStrength})";
          tooltip-format-disconnected = "Disconnected";
        };

        # Pulseaudio module
        "pulseaudio#icon" = {
          on-click = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
          format = "{icon}";
          format-muted = "";
          format-icons = {
            default = ["" ""];
          };
        };

        # Pulseaudio text module
        "pulseaudio#percentage" = {
          on-click = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
          format = "{volume}";
        };

        # Battery module
        "battery#icon" = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon}";
          format-warning = "<span foreground='#98bb6c'>{icon}</span>";
          format-critical = "<span foreground='#e46876'>{icon}</span>";
          format-charging = "<span foreground='#98bb6c'></span>";
          format-plugged = "<span foreground='#98bb6c'></span>";
          format-full = "<span foreground='#98bb6c'></span>";
          format-icons = ["󱃍" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
        };

        # Battery text module
        "battery#percentage" = {
          format = "{capacity}";
          tooltip-format = "{time}";
        };

        # Calendar icon module
        "clock#calendar-icon" = {
          format = "";
          tooltip-format = " <big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };

        # Clock text module (day of the week)
        "clock#day" = {
          format = "{:%a}";
          tooltip-format = " <big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };

        # Date text module (date)
        "clock#date" = {
          format = "{:%d}";
          tooltip-format = " <big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };

        # Time icon module
        "clock#time-icon" = {
          format = "󰥔";
          tooltip-format = "󰥔 {:%I:%M %p}";
        };

        # Clock text module (Time of day)
        "clock#time" = {
          format = "{:%H\n%M}";
          tooltip-format = "󰥔 {:%I:%M %p}";
        };
      }];

      # Appearance
      style = builtins.replaceStrings
        (builtins.attrNames theme.colourscheme)
        (builtins.attrValues theme.colourscheme)
        (builtins.readFile ./style.css);
    };
  };
}
