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
    bg-primary-bright = bright-black;
    bg-secondary = dark-grey;
    bg-secondary-bright = bright-dark-grey;

    # Foreground
    fg-primary = white;
    fg-primary-bright = bright-white;
    fg-secondary = light-grey;
    fg-secondary-bright = bright-light-grey;

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
    bright-red = "#bf616a";
    bright-green = "#a3be8c";
    bright-yellow = "#ebcb8b";
    bright-blue = "#5e81ac";
    bright-magenta = "#b48ead";
    bright-cyan = "#8fbcbb";
    bright-white = "#eceff4";
    bright-dark-grey = "#4c566a";
    bright-light-grey = "#e5e9f0";
  };
}
