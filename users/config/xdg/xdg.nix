{
  # Configure xdg
  xdg = {

    # Enable managing of xdg directories
    enable = true;

    # Support XDG Shared MIME-info specification
    mime.enable = true;

    # Allow files to be opened with appropriate programs
    mimeApps = {
      enable = true;

      # Configure default applications for mimetypes
      defaultApplications = {

        # Applications
        "application/zip" = ["org.gnome.Nautilus.desktop"];
        "application/octet-stream" = ["org.gnome.Nautilus.desktop" "chromium-browser.desktop"];
        "application/x-compressed-tar" = ["org.gnome.Nautilus.desktop"];
        "application/x-xz-compressed-tar" = ["org.gnome.Nautilus.desktop"];
        "application/json" = ["sublime_text.desktop"];

        # Directories
        "inode/directory" = ["org.gnome.Nautilus.desktop"];

        # Text
        "text/html" = ["sublime_text.desktop" "chromium-browser.desktop"];
        "text/markdown" = ["sublime_text.desktop"];
        "text/plain" = ["sublime_text.desktop"];
        "text/x-log" = ["sublime_text.desktop"];

        # Images
        "image/png" = ["org.gnome.gThumb.desktop" "chromium-browser.desktop"];
        "image/gif" = ["chromium-browser.desktop"];

        # Email
        "x-scheme-handler/mailto" = ["chromium-browser.desktop"];
      };
    };

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
