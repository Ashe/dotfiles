{ config, lib, pkgs, theme, ... }:

{
  # Enable Waybar
  programs.waybar = {
    enable = true;

    # Configure Waybar
    settings = 
    [
      {
        # Basics
        layer = "top";
        position = "top";
        height = 30;

        # Left modules
        modules-left = [ 
          "sway/workspaces" 
          "sway/mode" 
          "mpd" 
        ];

        # Central modules
        modules-center = [ 
          "sway/window" 
        ];

        # Right modules
        modules-right = [ 
          "cpu"
          "temperature"
          "temperature#gpu"
          "battery"
          "network"
          "pulseaudio"
          "tray"
          "clock"
        ];

        # Module configuration
        modules = {
          clock = {
            format = " {:%A, %d %B %I:%M %p}";
            tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          };
          cpu = {
            format = " {usage}%";
          };
          mpd = {
            format = "{stateIcon} {title}";
            format-paused = "{stateIcon} {title}";
            format-stopped = "";
            format-disconnected = "";
            state-icons = {
              playing = "";
              paused = "";
            };
          };
          network = {
            format-ethernet = " {bandwidthDownBits}";
            tooltip-format-ethernet = " {ifname} - {ipaddr}";
            format-wifi = " {essid} {bandwidthDownBits}";
            tooltip-format-wifi = " {ifname} - {ipaddr}";
            format-disconnected = "";
            tooltip-format-disconnected = "No internet connection";
          };
          pulseaudio = {
            format = "{icon} {volume}";
            format-bluetooth = "{icon} {volume}";
            format-muted = " {volume}";
            format-icons = {
              default = "";
              headphone = "";
              headset = "";
            };
            on-click = "pulseaudio-ctl mute";
            on-click-middle = "pavucontrol";
            on-click-right = "pavucontrol";
            all-outputs = true;
          };
          temperature = {
            format = "  CPU: {temperatureC}°C";
            format-critical = " CPU: {temperatureC}°C";
            tooltip = true;
            tooltip-format = " CPU: {temperatureC}°C";
            critical-threshhold = 80;
            hwmon-path = "/sys/class/hwmon/hwmon1/temp1_input";
          };
          "temperature#gpu" = {
            format = " GPU: {temperatureC}°C";
            format-critical = " GPU: {temperatureC}°C";
            tooltip = true;
            tooltip-format = " GPU: {temperatureC}°C";
            critical-threshhold = 80;
            hwmon-path = "/sys/class/drm/card0/device/hwmon/hwmon0/temp1_input";
          };
          "sway/mode" = {
            format = " {}";
          };
          "sway/window" = {
            format = " {}";
          };
          "sway/workspaces" = {
            format = "{icon}";
            enable-bar-scroll = true;
            format-icons = {
              default = "";
              focused = "";
              urgent = "";
            };
          };
        };
      }
    ];

    # Appearance
    style = builtins.replaceStrings 
        (builtins.attrNames theme.colourscheme) 
        (builtins.attrValues theme.colourscheme) 
        (builtins.readFile ./style.css);
  };
}
