{
  # Theme data
  data = (pkgs: {
    gtk-name = "Rose-Pine";
    gtk-package = pkgs.rose-pine-gtk-theme; 
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
    accent-primary = red;
    accent-secondary = bright-red;
    accent-tertiary = magenta;
    alert = red;
    warning = yellow;

    # Normal colours
    black = "#191724";
    red = "#eb6f92";
    green = "#a3be8c";
    yellow = "#f6c177";
    blue = "#31748f";
    magenta = "#c4a7e7";
    cyan = "#9ccfd8";
    white = "#e0def4";
    dark-grey = "#292734";
    light-grey = "#e4dfde";

    # Bright colours
    bright-black = "#6e6a86";
    bright-red = "#ebbcba";
    bright-green = "#b3ce9c";
    bright-yellow = "#ffd187";
    bright-blue = "#41849f";
    bright-magenta = "#d4b7f7";
    bright-cyan = "#acdfe8";
    bright-white = "#f0eeff";
    bright-dark-grey = "#7e7a96";
    bright-light-grey = "#f2ede9";
  };

  # Theme wallpaper
  wallpaper = "~/Pictures/wallpapers/rose-pine.png";
}
