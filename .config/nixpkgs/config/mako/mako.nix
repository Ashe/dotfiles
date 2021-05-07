{ config, lib, pkgs, ... }:

{
  # Configure Mako notification daemon
  programs.mako = {

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
    padding = "12,12,12,12";
    borderSize = 3;
    borderRadius = 3;

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

    # Colours
    backgroundColor = "#2E3440";
    borderColor = "#88C0D0";
    progressColor = "over #FFFFFF";
    textColor = "#ECEFF4";
  };
}
