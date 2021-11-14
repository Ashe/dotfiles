{ theme, ... }:

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

    # Colours
    backgroundColor = theme.colourscheme.bg-primary;
    borderColor = theme.colourscheme.bg-bright-secondary;
    progressColor = theme.colourscheme.fg-primary;
    textColor = theme.colourscheme.fg-primary;
  };
}
