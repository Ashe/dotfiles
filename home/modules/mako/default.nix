_: { config, lib, ... }:

{
  # Add options for mako notification system
  options.mako.enable = lib.mkEnableOption "mako";

  # Install mako if desired
  config = lib.mkIf config.mako.enable {

    # Configure Mako notification daemon
    services.mako = {

      # Enable mako
      enable = true;

      # Notification display settings
      maxVisible = 5;
      sort = "-time";

      # Allow programs to assign on-click actions
      actions = true;

      # Positioning and size
      anchor = "top-right";
      layer = "overlay";
      height = 200;
      width = 500;
      margin = "20,20,20,20";
      padding = "12,12,12,12";
      borderSize = 3;
      borderRadius = 25;

      # Layout of notification
      markup = true;
      format = ''
        <b>%s</b>\n%b
      '';

      # Icons
      icons = true;
      maxIconSize = 96;

      # Font
      font = "sans-serif 12";
    };
  };
}
