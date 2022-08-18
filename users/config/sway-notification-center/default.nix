{ pkgs, theme, ... }:

{
  # Install Sway Notification Center
  home.packages = [
    pkgs.swaynotificationcenter
  ];

  # Manage sway notification center settings
  xdg.configFile.swaync-settings = {
    source = ./config.json;
    target = "swaync/config.json";
  };

  # Manage sway notification center styling
  xdg.configFile.swaync-style = {
    target = "swaync/style.css";
    text = builtins.replaceStrings 
      (builtins.attrNames theme.colourscheme) 
      (builtins.attrValues theme.colourscheme) 
      (builtins.readFile ./style.css);
  };
}
