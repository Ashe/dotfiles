_: { config, lib, pkgs, ... }:

{
  # Add options for Gtk, toolkit for gnome
  options.gtk.config.enable = lib.mkEnableOption "gtk.config";

  # Configure Gtk if desired
  config = lib.mkIf config.gtk.config.enable {

    # Configure Gtk
    gtk = {

      # Enable Gtk configuration
      enable = true;

      # Set font
      font = {
        name = "Ubuntu";
        size = 12;
      };
    };
  };
}
