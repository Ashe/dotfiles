_: { config, lib, pkgs, ... }:

{
  # Add options for jellyfin, a media server
  options.jellyfin.enable = lib.mkEnableOption "jellyfin";

  # Install jellyfin if desired
  config = lib.mkIf config.jellyfin.enable {

    # Configure jellyfin
    services.jellyfin = {

      # Enable jellyfin
      enable = true;

      # Allow jellyfin to be accessed on local networks
      openFirewall = true;
    };

    # Install programs related to jellyfin
    environment.systemPackages = with pkgs; [

      # Desktop client for jellyfin
      jellyfin-media-player
    ];
  };
}
