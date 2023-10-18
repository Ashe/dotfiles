_: { config, lib, pkgs, ... }:

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
      };
    };
  };
}
