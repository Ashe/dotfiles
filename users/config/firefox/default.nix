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
      protondb-for-steam
      ublock-origin
    ];

    # Configure user profiles
    profiles.ashe = {
      id = 0;
      isDefault = true;
      settings = {
        "browser.newtabpage.enabled" = false;
        "browser.startup.homepage" = "https://start.duckduckgo.com";
      };
    };
  };
}
