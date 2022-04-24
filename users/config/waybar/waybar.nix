{ theme, ... }:

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
        position = "right";
        width = 100;

        # Left modules
        modules-left = [
          "custom/menu"
          "custom/terminal"
          "custom/filebrowser"
          "custom/browser"
          "custom/spotify-shortcut"
          "custom/discord"
          "sway/mode"
        ];

        # Right modules
        modules-right = [
          "custom/spotify-monitor"
          "custom/spotify-play-pause"
          "cpu"
          "network"
          "pulseaudio"
          "tray"
          "clock#day"
          "clock#date"
          "clock"
        ];

        # Module configuration
        modules = {

          # Current time and date
          "clock#day" = {
            format = "{:%A}";
            tooltip-format = "<big>  {:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          };

          # Current time and date
          "clock#date" = {
            format = "{:%d %b}";
            tooltip-format = "<big>  {:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          };

          # Current time and date
          "clock" = {
            format = "{:%I:%M %p}";
            tooltip-format = "<big>  {:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          };

          # CPU usage
          cpu = {
            format = "  {usage}%";
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
            disable-scroll-wraparound = true;
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
            on-click = "$FILEGUI --new-window";
            on-click-middle = "pkill $FILEGUI";
            tooltip = false;
          };

          # Browser shortcut
          "custom/browser" = {
            format = "";
            on-click = "$BROWSER";
            on-click-middle = "pkill $BROWSER";
            tooltip = false;
          };

          # Discord shortcut
          "custom/discord" = {
            format = "";
            on-click = "discord";
            on-click-middle = "pkill discord";
            tooltip = false;
          };

          # Shortcut for spotify
          "custom/spotify-shortcut" = {
            format = "";
            on-click = "spotify";
            on-click-middle = "pkill spotify";
            tooltip = false;
          };

          # Continuously polls Spotify
          "custom/spotify-monitor" = {
            interval = 1;
            exec = "waybar-spotify-monitor.sh";
            signal = 4;
            tooltip = false;
          };

          # Shows detail about current Spotify song
          "custom/spotify-metadata" = {
            format = "  {}";
            max-length = 500;
            interval = "once";
            return-type = "json";
            exec = "waybar-spotify-metadata.sh";
            on-click = "waybar-spotify-controls.sh";
            signal = 5;
          };

          # Allows the playing or pausing of Spotify
          "custom/spotify-play-pause" = {
            format = "{}";
            interval = "once";
            return-type = "json";
            exec = "waybar-spotify-play-pause.sh";
            on-click = "waybar-spotify-controls.sh";
            on-click-right = "waybar-spotify-controls.sh next";
            on-scroll-up = "waybar-spotify-controls.sh next";
            on-click-middle = "waybar-spotify-controls.sh prev";
            on-scroll-down = "waybar-spotify-controls.sh prev";
            signal = 5;
          };

          # Skip to next Spotify song
          "custom/spotify-next" = {
            format = "";
            return-type = "json";
            interval = "once";
            exec = "waybar-spotify-metadata.sh";
            on-click = "waybar-spotify-controls.sh next";
            signal = 5;
          };

          # Skip to previous Spotify song
          "custom/spotify-prev" = {
            format = "";
            interval = "once";
            return-type = "json";
            exec = "waybar-spotify-metadata.sh";
            on-click = "waybar-spotify-controls.sh prev";
            signal = 5;
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
