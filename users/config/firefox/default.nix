{ config, ... }:

{
  # Configure Firefox web browser
  programs.firefox = {

    # Install Firefox
    enable = true;

    # Install default extensions
    extensions = with config.nur.repos.rycee.firefox-addons; [
      betterttv
      bitwarden
      https-everywhere
      i-dont-care-about-cookies
      protondb-for-steam
      ublock-origin
    ];

    # Configure user profiles
    profiles.ashe = {
      id = 0;
      isDefault = true;
      settings = {

        # Disable the Firefox new-tab-page
        "browser.newtabpage.enabled" = false;

        # Set homepage to duckduckgo
        "browser.startup.homepage" = "https://start.duckduckgo.com";

        # Allow tiling of fullscreen windows
        "full-screen-api.ignore-widgets" = true;
      };
    };
  };
}
