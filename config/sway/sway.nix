{ config, lib, pkgs, ... }:

with lib;

let 
  cfg = config.wayland.windowManager.sway;
in
{

  # Enable Sway for Wayland
  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true;

    # Configure sway
    config = {
    
      # Configure monitor outputs
      output = {
        DP-1 = {
          mode = "5120x1440";
          bg = "~/Pictures/wallpaper.png center";
        };
      };

      # Use waybar as the default bar
      bars = [
        { command = "waybar"; }
      ];

      # Create gaps (unless only one container)
      gaps.smartGaps = true;
      gaps.inner = 10;

      # Set default programs
      terminal = "st";
      menu = "wofi";

      # Change modifier to Super
      modifier = "Mod4";

      # Startup commands
      startup = [
        { command = "blueman-applet"; }
        { command = "dropbox start"; }
        { command = "mako"; }
      ];

      # Keybindings
      keybindings = {

        # Basics
        "${cfg.config.modifier}+Shift+w" = "kill";
        "${cfg.config.modifier}+space" = "exec ${cfg.config.menu} --show drun -w 3 -i -I";
        "${cfg.config.modifier}+Escape" = "exec wlogout";
        "${cfg.config.modifier}+BackSpace" = "reload";
        "${cfg.config.modifier}+Control+Shift+BackSpace" =
          "exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -b 'Yes, exit sway' 'swaymsg exit'";

        # Program shortcuts
        "${cfg.config.modifier}+Return" = "exec ${cfg.config.terminal}";
        "${cfg.config.modifier}+1" = "exec $FILEGUI --new-window";
        "${cfg.config.modifier}+2" = "exec $BROWSER";
        "${cfg.config.modifier}+3" = "exec ${cfg.config.terminal} -e ncmpcpp";
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
        "${cfg.config.modifier}+i" = "workspace prev_on_output --create";
        "${cfg.config.modifier}+o" = "workspace next_on_output -- create";
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
          background = "#3b4252"; 
          border = "#3b5252"; 
          childBorder = "";
          indicator = "#454948"; 
          text = "#81a1c1";
        };
        focused = {
          background = "#81a1c1"; 
          border = "#81a1c1"; 
          childBorder = "";
          indicator = "#d08770"; 
          text = "#d8dee9";
        };
        focusedInactive = {
          background = "#3b4252"; 
          border = "#3b4252"; 
          childBorder = "";
          indicator = "#454948"; 
          text = "#81a1c1";
        };
        urgent = {
          background = "#d8dee9"; 
          border = "#d08770"; 
          childBorder = "";
          indicator = "#5e81ac";
          text = "#81a1c1";
        };
        placeholder = {
          background = "#d8dee9"; 
          border = "#000000"; 
          childBorder = "";
          indicator = "#5e81ac"; 
          text = "#81a1c1";
        };
      };
    };
  };
}
