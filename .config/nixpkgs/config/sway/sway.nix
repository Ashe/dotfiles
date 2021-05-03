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
        { command = "mpd"; }
      ];

      # Keybindings
      keybindings = {

        # Basics
        "${cfg.config.modifier}+Return" = "exec ${cfg.config.terminal}";
        "${cfg.config.modifier}+Shift+w" = "kill";
        "${cfg.config.modifier}+space" = "exec ${cfg.config.menu} --show run";
        "${cfg.config.modifier}+BackSpace" = "reload";
        "${cfg.config.modifier}+Control+Shift+BackSpace" =
          "exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -b 'Yes, exit sway' 'swaymsg exit'";

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

        # Enter fullscreen mode for currently focused container
        "${cfg.config.modifier}+Shift+f" = "fullscreen toggle";

        # Change container layout
        "${cfg.config.modifier}+t" = "split toggle, layout tabbed";
        "${cfg.config.modifier}+Shift+t" = "layout toggle split";

        # Toggle tiling / floating containers
        "${cfg.config.modifier}+s" = "floating toggle";
        "${cfg.config.modifier}+Shift+s" = "focus mode_toggle";

        # Change workspaces
        "${cfg.config.modifier}+1" = "workspace number 1";
        "${cfg.config.modifier}+2" = "workspace number 2";
        "${cfg.config.modifier}+3" = "workspace number 3";
        "${cfg.config.modifier}+4" = "workspace number 4";
        "${cfg.config.modifier}+5" = "workspace number 5";
        "${cfg.config.modifier}+6" = "workspace number 6";
        "${cfg.config.modifier}+7" = "workspace number 7";
        "${cfg.config.modifier}+8" = "workspace number 8";
        "${cfg.config.modifier}+9" = "workspace number 9";

        # Move containers to specific workspace
        "${cfg.config.modifier}+Shift+1" =
          "move container to workspace number 1";
        "${cfg.config.modifier}+Shift+2" =
          "move container to workspace number 2";
        "${cfg.config.modifier}+Shift+3" =
          "move container to workspace number 3";
        "${cfg.config.modifier}+Shift+4" =
          "move container to workspace number 4";
        "${cfg.config.modifier}+Shift+5" =
          "move container to workspace number 5";
        "${cfg.config.modifier}+Shift+6" =
          "move container to workspace number 6";
        "${cfg.config.modifier}+Shift+7" =
          "move container to workspace number 7";
        "${cfg.config.modifier}+Shift+8" =
          "move container to workspace number 8";
        "${cfg.config.modifier}+Shift+9" =
          "move container to workspace number 9";

        "${cfg.config.modifier}+Shift+minus" = "move scratchpad";
        "${cfg.config.modifier}+minus" = "scratchpad show";

        "${cfg.config.modifier}+r" = "mode resize";
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
