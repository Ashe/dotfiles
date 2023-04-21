_: { config, lib, pkgs, theme, ... }:

{
  # Add options for swaylock, lock screen for wayland
  options.swaylock.enable = lib.mkEnableOption "swaylock.config";

  # Configure swaylock if desired
  config = lib.mkIf config.swaylock.enable {

    # Configure swaylock
    programs.swaylock = {

      # Install swaylock
      enable = true;

      # Enable extra effects via a modified package
      package = pkgs.swaylock-effects;

      # Customise the appearance of swaylock
      settings = {

        # Show number of failed attempts
        show-failed-attempts = true;

        # Take a screenshot of the current desktop
        screenshots = true;

        # Display the current time
        clock = true;
        timestr = "%I:%M:%S %p";
        datestr = "%A %d %B %Y";

        # Display an idle indicator
        indicator = true;
        indicator-idle-visible = true;
        indicator-radius = 128;
        indicator-thickness = 7;

        # Blur background
        effect-blur = "7x5";
        effect-vignette = "0.5:0.5";
        fade-in = 0.2;

        # Inside colours
        inside-color = theme.colourscheme.bg-dark-primary;
        inside-ver-color = theme.colourscheme.bg-dark-primary;
        inside-clear-color = theme.colourscheme.bg-dark-primary;
        inside-caps-lock-color = theme.colourscheme.bg-dark-primary;
        inside-wrong-color = theme.colourscheme.bg-dark-primary;

        # Ring colours
        ring-color = "00000000";
        ring-ver-color = "00000000";
        ring-clear-color = "00000000";
        ring-caps-lock-color = "00000000";
        ring-wrong-color = "00000000";

        # Line colours
        line-color = "00000000";
        line-ver-color = theme.colourscheme.bg-secondary;
        line-clear-color = "00000000";
        line-caps-lock-color = theme.colourscheme.warning;
        line-wrong-color = theme.colourscheme.alert;

        # Text colours
        text-color = theme.colourscheme.fg-primary;
        text-ver-color = theme.colourscheme.fg-primary;
        text-clear-color = theme.colourscheme.fg-primary;
        text-caps-lock-color = theme.colourscheme.fg-primary;
        text-wrong-color = theme.colourscheme.fg-primary;

        # Key colour
        separator-color = "00000000";
        key-hl-color = theme.colourscheme.accent-primary;
      };
    };
  };
}
