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
      settings = {};
    };

    # Set environment variables
    home.sessionVariables = {
      TERMINAL = "kitty";
    };
  };
}
