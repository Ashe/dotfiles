{ theme, ...}:

{
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
    };
  };
}
