{ config, lib, pkgs, ... }:

with lib;

{
  # Configure xdg
  xdg = {

    # Enable managing of xdg directories
    enable = true;

    # Allow programs and files to be opened with appropriate programs
    mime.enable = true;

    # Configure system directories
    systemDirs = {

      # Directory names to add to XDG_CONFIG_DIRS
      config = [];

      # Directory names to add to XDG_DATA_DIRS
      data = [];
    };

    # Configure user directories
    userDirs = {

      # Enable management of user directories
      enable = true;
      createDirectories = true;

      # Set directories
      desktop = "$HOME/Desktop";
      documents = "$HOME/Documents";
      download = "$HOME/Downloads";
      music = "$HOME/Music";
      pictures = "$HOME/Pictures";
      publicShare = "$HOME/Public";
      templates = "$HOME/Templates";
      videos = "$HOME/Videos";

      # Configure additional directories
      extraConfig = {
        XDG_SCREENSHOTS_DIR = "$HOME/Pictures/Screenshots";
      };
    };
  };
}
