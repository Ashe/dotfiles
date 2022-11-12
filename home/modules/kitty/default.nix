_: { config, lib, pkgs, theme, ... }:

{
  # Add options for kitty terminal emulator
  options.kitty.enable = lib.mkEnableOption "kitty";

  # Install kitty if desired
  config = lib.mkIf config.kitty.enable {

    # Configure kitty terminal
    programs.kitty = {

      # Enable kitty
      enable = true;

      # Configure font
      font = {
        name = "FiraCode Nerd Font";
        size = 12;
      };

      # Set colourscheme
      theme = theme.data.kitty.name;

      # Kitty settings
      settings = {

        # Wipe default keybindings
        "clear_all_shortcuts" = "yes";
      };

      # Keybindings
      keybindings = {

        # Window management
        "ctrl+shift+enter" = "new_window";
        "ctrl+shift+d" = "close_window";
        "ctrl+shift+r" = "start_resizing_window";

        # Window navigation
        "ctrl+shift+h" = "neighboring_window left";
        "ctrl+shift+j" = "neighboring_window down";
        "ctrl+shift+k" = "neighboring_window up";
        "ctrl+shift+l" = "neighboring_window right";

        # Window movement
        "ctrl+shift+alt+h" = "move_window left";
        "ctrl+shift+alt+j" = "move_window down";
        "ctrl+shift+alt+k" = "move_window up";
        "ctrl+shift+alt+l" = "move_window right";

        # Layouts
        "ctrl+shift+e" = "next_layout";
      };
    };

    # Set environment variables
    home.sessionVariables = {
      TERMINAL = "kitty";
    };
  };
}
