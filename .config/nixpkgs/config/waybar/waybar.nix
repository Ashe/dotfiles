{ config, lib, pkgs, ... }:

with lib;

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
            format = " {temperatureC}°C";
            format-critical = " {temperatureC}°C";
            critical-threshhold = 80;
            hwmon-path = "/sys/class/hwmon/hwmon1/temp1_input";
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
    style = ''

      * {
          border: none;
          border-radius: 0;
          /* `otf-font-awesome` is required to be installed for icons */
          font-family: Roboto, Helvetica, Arial, sans-serif;
          font-size: 13px;
          min-height: 0;
      }

      window#waybar {
          background-color: rgba(43, 48, 59, 0.5);
          border-bottom: 3px solid rgba(100, 114, 125, 0.5);
          color: #ffffff;
          transition-property: background-color;
          transition-duration: .5s;
      }

      window#waybar.hidden {
          opacity: 0.2;
      }

      /*
      window#waybar.empty {
          background-color: transparent;
      }
      window#waybar.solo {
          background-color: #FFFFFF;
      }
      */

      window#waybar.termite {
          background-color: #3F3F3F;
      }

      window#waybar.chromium {
          background-color: #000000;
          border: none;
      }

      #workspaces button {
          padding: 0 5px;
          background-color: transparent;
          color: #ffffff;
          /* Use box-shadow instead of border so the text isn't offset */
          box-shadow: inset 0 -3px transparent;
      }

      /* https://github.com/Alexays/Waybar/wiki/FAQ#the-workspace-buttons-have-a-strange-hover-effect */
      #workspaces button:hover {
          background: rgba(0, 0, 0, 0.2);
          box-shadow: inset 0 -3px #ffffff;
      }

      #workspaces button.focused {
          background-color: #64727D;
          box-shadow: inset 0 -3px #ffffff;
      }

      #workspaces button.urgent {
          background-color: #eb4d4b;
      }

      #mode {
          background-color: #64727D;
          border-bottom: 3px solid #ffffff;
      }

      #clock,
      #battery,
      #cpu,
      #memory,
      #disk,
      #temperature,
      #backlight,
      #network,
      #pulseaudio,
      #custom-media,
      #tray,
      #mode,
      #idle_inhibitor,
      #mpd {
          padding: 0 10px;
          margin: 0 4px;
          color: #ffffff;
      }

      #window,
      #workspaces {
          margin: 0 4px;
      }

      /* If workspaces is the leftmost module, omit left margin */
      .modules-left > widget:first-child > #workspaces {
          margin-left: 0;
      }

      /* If workspaces is the rightmost module, omit right margin */
      .modules-right > widget:last-child > #workspaces {
          margin-right: 0;
      }

      #clock {
          background-color: #4C566A;
      }

      #battery {
          background-color: #ffffff;
          color: #000000;
      }

      #battery.charging, #battery.plugged {
          color: #ffffff;
          background-color: #26A65B;
      }

      @keyframes blink {
          to {
              background-color: #ffffff;
              color: #000000;
          }
      }

      #battery.critical:not(.charging) {
          background-color: #f53c3c;
          color: #ffffff;
          animation-name: blink;
          animation-duration: 0.5s;
          animation-timing-function: linear;
          animation-iteration-count: infinite;
          animation-direction: alternate;
      }

      label:focus {
          background-color: #000000;
      }

      #cpu {
          background-color: #A3BE8C;
          border-bottom: 3px solid #C3DEAC;
          color: #000000;
      }

      #memory {
          background-color: #9b59b6;
      }

      #disk {
          background-color: #964B00;
      }

      #backlight {
          background-color: #90b1b1;
      }

      #network {
          background-color: #81A1C1;
          border-bottom: 3px solid #A1C1E1;
          color: #000000;
      }

      #network.disconnected {
          background-color: #BF616A;
          border-bottom: 3px solid #DF818A;
          color: #000000;
      }

      #pulseaudio {
          background-color: #EBCB8B;
          border-bottom: 3px solid #FFEBAB;
          color: #000000;
      }

      #pulseaudio.muted {
          background-color: #BF616A;
          border-bottom: 3px solid #DF818A;
          color: #000000;
      }

      #custom-media {
          background-color: #66cc99;
          color: #2a5c45;
          min-width: 100px;
      }

      #custom-media.custom-spotify {
          background-color: #66cc99;
      }

      #custom-media.custom-vlc {
          background-color: #ffa000;
      }

      #temperature {
          background-color: #8FBCBB;
          border-bottom: 3px solid #AFDCDB;
          color: #000000;
      }

      #temperature.critical {
          background-color: #D08770;
          border-bottom: 3px solid #F0A790;
          color: #000000;
      }

      #tray {
          background-color: #3B4252;
          border-bottom: 3px solid #4C566A;
      }

      #idle_inhibitor {
          background-color: #2d3436;
      }

      #idle_inhibitor.activated {
          background-color: #ecf0f1;
          color: #2d3436;
      }

      #mpd {
          background-color: #A3BE8C;
          border-bottom: 3px solid #C3DEAC;
          color: #000000;
      }

      #mpd.paused {
          background-color: #BF616A;
          border-bottom: 3px solid #DF818A;
          color: #000000;
      }

      #mpd.disconnected,
      #mpd.stopped {
          background-color: #3B4252;
          border-bottom: 3px solid #4C566A;
      }

      #language {
          background: #00b093;
          color: #740864;
          padding: 0 5px;
          margin: 0 5px;
          min-width: 16px;
      }
    '';
  };
}
