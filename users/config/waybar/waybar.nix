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
        height = 20;

        # Left modules
        modules-left = [ 
          "custom/menu"
          "custom/terminal"
          "custom/filebrowser"
          "custom/browser"
          "custom/guilded"
          "mpd" 
          "sway/mode" 
        ];

        # Central modules
        modules-center = [ 
          "sway/workspaces" 
        ];

        # Right modules
        modules-right = [ 
          "cpu"
          "battery"
          "network"
          "pulseaudio"
          "tray"
          "clock"
        ];

        # Module configuration
        modules = {

          # Current time and date
          clock = {
            format = "  {:%a, %d %b %I:%M %p}";
            tooltip-format = "<big>  {:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          };

          # CPU usage
          cpu = {
            format = "  {usage}%";
          };

          # MPD music daemon
          mpd = {
            format = "{stateIcon}  {title}";
            format-paused = "{stateIcon}";
            format-stopped = "";
            format-disconnected = "";
            state-icons = {
              playing = "";
              paused = "";
            };
            tooltip-format = "  {title} | {artist} | {album}";
            tooltip-format-disconnected = "  (disconnected)";
          };

          # Network usage
          network = {
            format-ethernet = "  {bandwidthDownBits}";
            tooltip-format-ethernet = "  {bandwidthDownBits} - {ipaddr}";
            format-wifi = " {essid} {bandwidthDownBits}";
            tooltip-format-wifi = " {ifname} - {ipaddr}";
            format-disconnected = "";
            tooltip-format-disconnected = "No internet connection";
          };

          # Volume slider
          pulseaudio = {
            format = "{icon}  {volume}";
            format-bluetooth = "{icon} {volume}";
            format-muted = "  {volume}";
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

          # Current sway mode (resize etc)
          "sway/mode" = {
            format = "  {}";
          };

          # Current sway workspaces
          "sway/workspaces" = {
            format = "{icon}";
            enable-bar-scroll = true;
            format-icons = {
              default = "";
              focused = "";
              urgent = "";
            };
          };

          # App tray
          tray = {
            icon-size = 18;
            spacing = 8;
          };

          # Menu shortcut
          "custom/menu" = {
            format = "";
            on-click = "$MENU";
            on-click-right = "wlogout";
            tooltip = false;
          };

          # Terminal shortcut
          "custom/terminal" = {
            format = "";
            on-click = "$TERMINAL";
            tooltip = false;
          };

          # File browser shortcut
          "custom/filebrowser" = {
            format = "";
            on-click = "$FILEGUI";
            tooltip = false;
          };

          # Browser shortcut
          "custom/browser" = {
            format = "";
            on-click = "$BROWSER";
            tooltip = false;
          };

          # Guilded shortcut
          "custom/guilded" = {
            format = "";
            on-click = "flatpak run gg.guilded.Guilded";
            tooltip = false;
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
