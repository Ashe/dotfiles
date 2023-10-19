_: { config, lib, pkgs, ... }:

{
  # Add options for qt, a gui toolkit
  options.qt.config.enable = lib.mkEnableOption "qt.config";

  # Configure qt if desired
  config = lib.mkIf config.gtk.config.enable {

    # Enable qt configuration
    qt.enable = true;

    # Set environment variables
    home.sessionVariables = {
      QT_QPA_PLATFORM = "wayland";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = 1;
      QT_AUTO_SCREEN_SCALE_FACTOR = 1;
    };

    # Configure qt5
    # Note that we use .text here so that theming can append to it
    xdg.configFile."qt5ct/qt5ct.conf".text = builtins.readFile ./qt5ct.conf;
  };
}
