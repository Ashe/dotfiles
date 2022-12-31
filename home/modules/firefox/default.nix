_: { config, lib, pkgs, ... }:

{
  # Add options for firefox web browser
  options.firefox.enable = lib.mkEnableOption "firefox";

  # Install firefox if desired
  config = lib.mkIf config.firefox.enable {

    # Configure Firefox web browser
    programs.firefox = {

      # Install Firefox
      enable = true;

      # Use nightly version of firefox
      package = with pkgs; firefox-wayland;

      # Install default extensions
      extensions = with config.nur.repos.rycee.firefox-addons; [
        betterttv
        bitwarden
        https-everywhere
        protondb-for-steam
        ublock-origin
        web-scrobbler
      ];

      # Configure user profiles
      profiles.ashe = {
        id = 0;
        isDefault = true;
        settings = {

          # Disable the Firefox new-tab-page
          "browser.newtabpage.enabled" = false;

          # Set startup page
          # 0=blank, 1=home, 2=last visited page, 3=resume previous session
          "browser.startup.page" = 3;

          # Set a blank homepage
          "browser.startup.homepage" = "about:blank";

          # Allow tiling of fullscreen windows
          "full-screen-api.ignore-widgets" = true;

          # Disable popup when mic or webcam is active
          "privacy.webrtc.legacyGlobalIndicator" = false;
        };
      };
    };

    # Set environment variables
    home.sessionVariables = {

      # Use wayland version of firefox
      MOZ_ENABLE_WAYLAND = 1;
    };
  };
}
