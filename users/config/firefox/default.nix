{ pkgs, config, ... }:

{
  # Configure Firefox web browser
  programs.firefox = {

    # Install Firefox
    enable = true;

    # Use Wayland version of Firefox for screen sharing
    package = pkgs.wrapFirefox pkgs.firefox-unwrapped {
      forceWayland = true;
      extraPolicies = {
        ExtensionSettings = {};
      };
    };

    # Install default extensions
    extensions = with config.nur.repos.rycee.firefox-addons; [
      betterttv
      bitwarden
      https-everywhere
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

        # Set startup page
        # 0=blank, 1=home, 2=last visited page, 3=resume previous session
        "browser.startup.page" = 3;

        # Set a blank homepage
        "browser.startup.homepage" = "about:blank";

        # Allow tiling of fullscreen windows
        "full-screen-api.ignore-widgets" = true;
      };
    };
  };

  # Set environment variables
  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = 1;
  };
}
