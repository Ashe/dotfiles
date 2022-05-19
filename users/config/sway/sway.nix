{ config, theme, ... }:

let
  cfg = config.wayland.windowManager.sway;
  colours = theme.colourscheme;
in
{

  # Configure sway for Wayland
  wayland.windowManager.sway = {

    # Enable sway
    enable = true;

    # Enable xwayland compatibility layer for running X applications
    xwayland = true;

    # Allow sway to facilitate GTK applications
    wrapperFeatures.gtk = true;

    # Configure sway
    config = {

      # Configure monitor outputs
      output = {
        DP-1 = {
          mode = "5120x1440";
          bg = "${theme.wallpaper} fill";
        };
      };

      # Use waybar as the default bar
      bars = [
        { command = "waybar"; }
      ];

      # Create gaps
      gaps.inner = 10;

      # Never steal focus
      focus.newWindow = "urgent";

      # Change modifier to Super
      modifier = "Mod4";

      # Startup commands
      startup = [
        { command = "blueman-applet"; }
        { command = "dropbox start"; }
        { command = "mako"; }
      ];

      # Allows quick returning to previous workspace
      workspaceAutoBackAndForth = true;

      # Configure input devices
      input = {

        # Graphics tablet
        "1386:770:Wacom_Intuos_PT_S_Pen" = {
          map_from_region = "0.1644x0.148 0.8355x0.752";
          map_to_region = "1280 0 2560 1440";
        };
      };

      # Keybindings
      keybindings = {

        # Basics
        "${cfg.config.modifier}+Shift+w" = "kill";
        "${cfg.config.modifier}+space" = "exec $MENU";
        "${cfg.config.modifier}+Escape" = "exec wlogout";
        "${cfg.config.modifier}+BackSpace" = "reload";
        "${cfg.config.modifier}+Control+Shift+BackSpace" =
          "exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -b 'Yes, exit sway' 'swaymsg exit'";

        # Program shortcuts
        "${cfg.config.modifier}+Return" = "exec $TERMINAL";
        "${cfg.config.modifier}+1" = "exec $FILEGUI --new-window";
        "${cfg.config.modifier}+2" = "exec $BROWSER";
        "${cfg.config.modifier}+3" = "exec $MUSIC";
        "${cfg.config.modifier}+Shift+s" = "exec wl-copy -t image/png < $(grimshot save area)";
        "Print" = "exec wl-copy -t image/png < $(grimshot save area)";

        # Multimedia
        XF86AudioRaiseVolume = "exec pulseaudio-ctl up";
        XF86AudioLowerVolume = "exec pulseaudio-ctl down";
        XF86AudioMute = "exec pulseaudio-ctl mute";
        XF86AudioPlay = "exec mpc toggle";
        XF86AudioPrev = "exec mpc prev";
        XF86AudioNext = "exec mpc next";

        # Focus navigation
        "${cfg.config.modifier}+${cfg.config.left}" = "focus left";
        "${cfg.config.modifier}+${cfg.config.down}" = "focus down";
        "${cfg.config.modifier}+${cfg.config.up}" = "focus up";
        "${cfg.config.modifier}+${cfg.config.right}" = "focus right";
        "${cfg.config.modifier}+Left" = "focus left";
        "${cfg.config.modifier}+Down" = "focus down";
        "${cfg.config.modifier}+Up" = "focus up";
        "${cfg.config.modifier}+Right" = "focus right";

        # Focus parent / children
        "${cfg.config.modifier}+a" = "focus parent";
        "${cfg.config.modifier}+d" = "focus child";

        # Movement
        "${cfg.config.modifier}+Shift+${cfg.config.left}" = "move left";
        "${cfg.config.modifier}+Shift+${cfg.config.down}" = "move down";
        "${cfg.config.modifier}+Shift+${cfg.config.up}" = "move up";
        "${cfg.config.modifier}+Shift+${cfg.config.right}" = "move right";
        "${cfg.config.modifier}+Shift+Left" = "move left";
        "${cfg.config.modifier}+Shift+Down" = "move down";
        "${cfg.config.modifier}+Shift+Up" = "move up";
        "${cfg.config.modifier}+Shift+Right" = "move right";

        # Split in horizontal or vertical directions
        "${cfg.config.modifier}+Control+space" = "splitv";
        "${cfg.config.modifier}+Control+Return" = "splith";

        # Navigate workspaces
        "${cfg.config.modifier}+i" = "workspace prev_on_output";
        "${cfg.config.modifier}+o" = "workspace next_on_output --create";
        "${cfg.config.modifier}+Shift+i" = "move container to workspace prev, workspace prev";
        "${cfg.config.modifier}+Shift+o" = "move container to workspace next, workspace next";

        # Enter fullscreen mode for currently focused container
        "${cfg.config.modifier}+Shift+f" = "fullscreen toggle";

        # Resize containers
        "${cfg.config.modifier}+r" = "mode resize";

        # Change container layout
        "${cfg.config.modifier}+t" = "split toggle, layout tabbed";
        "${cfg.config.modifier}+Shift+t" = "layout toggle split";

        # Toggle tiling / floating containers
        "${cfg.config.modifier}+s" = "floating toggle";
        "${cfg.config.modifier}+Control+s" = "focus mode_toggle";

        # Send programs to scratchpad
        "${cfg.config.modifier}+Shift+minus" = "move scratchpad";
        "${cfg.config.modifier}+minus" = "scratchpad show";
      };

      # Configure colours
      colors = {
        unfocused = {
          background = colours.bg-primary;
          border = colours.bg-secondary;
          childBorder = "";
          indicator = colours.bg-secondary;
          text = colours.fg-secondary;
        };
        focused = {
          background = colours.accent-primary;
          border = colours.accent-primary;
          childBorder = "";
          indicator = colours.warning;
          text = colours.fg-bright-primary;
        };
        focusedInactive = {
          background = colours.bg-primary;
          border = colours.bg-secondary;
          childBorder = "";
          indicator = colours.bg-primary;
          text = colours.fg-secondary;
        };
        urgent = {
          background = colours.bg-primary;
          border = colours.alert;
          childBorder = "";
          indicator = colours.accent-primary;
          text = colours.fg-secondary;
        };
        placeholder = {
          background = colours.fg-primary;
          border = colours.bg-primary;
          childBorder = "";
          indicator = colours.accent-primary;
          text = colours.fg-secondary;
        };
      };
    };
  };
}
