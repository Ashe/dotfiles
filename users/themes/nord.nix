{
  # Theme data
  data = (pkgs: {
    gtk-name = "Nordic";
    gtk-package = pkgs.nordic; 
  });

  # Theme colourscheme
  colourscheme = rec {

    # Background
    bg-primary = black;
    bg-bright-primary = bright-black;
    bg-secondary = dark-grey;
    bg-bright-secondary = bright-dark-grey;

    # Foreground
    fg-primary = white;
    fg-bright-primary = bright-white;
    fg-secondary = light-grey;
    fg-bright-secondary = bright-light-grey;

    # Additional
    accent-primary = blue;
    accent-secondary = green;
    accent-tertiary = magenta;
    alert = red;
    warning = yellow;

    # Normal colours
    black = "#2e3440";
    red = "#bf616a";
    green = "#a3be8c";
    yellow = "#ebcb8b";
    blue = "#81a1c1";
    magenta = "#b48ead";
    cyan = "#88c0d0";
    white = "#e5e9f0";
    dark-grey = "#3b4252";
    light-grey = "#d8dee9";

    # Bright colours
    bright-black = "#434c5e";
    bright-red = "#cf717a";
    bright-green = "#b3ce9c";
    bright-yellow = "#fbdb9b";
    bright-blue = "#91b1d1";
    bright-magenta = "#c49ebd";
    bright-cyan = "#8fbcbb";
    bright-white = "#eceff4";
    bright-dark-grey = "#4c566a";
    bright-light-grey = "#e5e9f0";
  };

  # Theme wallpaper
  wallpaper = "~/Pictures/wallpapers/nord.png";
}
