_: { config, lib, pkgs, theme, ... }:

{
  # Add options for gtk, toolkit for gnome
  options.gtk.config.enable = lib.mkEnableOption "gtk.config";

  # Configure gtk if desired
  config = lib.mkIf config.gtk.config.enable {

    # Configure GTK
    gtk = {

      # Enable GTK customisation
      enable = true;

      # Set theme
      theme = theme.data.gtk;

      # Set icon theme
      iconTheme = {
        name = "Papirus";
        package = pkgs.papirus-icon-theme;
      };

      # Set font
      font = {
        name = "Ubuntu";
        size = 12;
      };
    };
  };
}
