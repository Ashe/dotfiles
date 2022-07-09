{ theme, ... }:

{
  # Place additional files in .config/waybar/extra
  xdg.configFile.waybar = {
    source = ./extra;
    target = "waybar/extra";
  };

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
          "custom/notifications"
        ];


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
          format-ethernet = " ";
          tooltip-format-ethernet = "  {bandwidthDownBits} - {ipaddr}";
          format-wifi = " {essid}";
          tooltip-format-wifi = "  {bandwidthDownBits} - {ifname} - {ipaddr}";
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

        # Notification center
        "custom/notifications" = {
          tooltip = false;
          format = "{icon}";
          format-icons = {
            notification = "<span foreground='red'><sup></sup></span>";
            none = "";
            dnd-notification = "<span foreground='red'><sup></sup></span>";
            dnd-none = "";
          };
          return-type = "json";
          exec-if = "which swaync-client";
          exec = "swaync-client -swb";
          on-click = "swaync-client -t -sw";
          on-click-right = "swaync-client -d -sw";
          escape = true;
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
          exec = "/home/ashe/.config/waybar/extra/spotify/monitor.sh";
          signal = 4;
          tooltip = false;
        };

        # Shows detail about current Spotify song
        "custom/spotify-metadata" = {
          format = "  {}";
          max-length = 500;
          interval = "once";
          return-type = "json";
          exec = "/home/ashe/.config/waybar/extra/spotify/metadata.sh";
          on-click = "/home/ashe/.config/waybar/extra/spotify/controls.sh";
          signal = 5;
        };

        # Allows the playing or pausing of Spotify
        "custom/spotify-play-pause" = {
          format = "{}";
          interval = "once";
          return-type = "json";
          exec = "/home/ashe/.config/waybar/extra/spotify/play-pause.sh";
          on-click = "/home/ashe/.config/waybar/extra/spotify/controls.sh";
          on-click-right = "/home/ashe/.config/waybar/extra/spotify/controls.sh next";
          on-scroll-up = "/home/ashe/.config/waybar/extra/spotify/controls.sh next";
          on-click-middle = "/home/ashe/.config/waybar/extra/spotify/controls.sh prev";
          on-scroll-down = "/home/ashe/.config/waybar/extra/spotify/controls.sh prev";
          signal = 5;
        };

        # Skip to next Spotify song
        "custom/spotify-next" = {
          format = "";
          return-type = "json";
          interval = "once";
          exec = "/home/ashe/.config/waybar/extra/spotify/metadata.sh";
          on-click = "/home/ashe/.config/waybar/extra/spotify/controls.sh next";
          signal = 5;
        };

        # Skip to previous Spotify song
        "custom/spotify-prev" = {
          format = "";
          interval = "once";
          return-type = "json";
          exec = "/home/ashe/.config/waybar/extra/spotify/metadata.sh";
          on-click = "/home/ashe/.config/waybar/extra/spotify/controls.sh prev";
          signal = 5;
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
