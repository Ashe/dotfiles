{ config, lib, pkgs, ... }:

{
  options.jellyfin.enable = lib.mkEnableOption "jellyfin";

  config = lib.mkIf config.jellyfin.enable {

    # Configure jellyfin
    services.jellyfin = {
      enable = true;
      openFirewall = true;
    };

    # Install programs related to jellyfin
    environment.systemPackages = with pkgs; [

      # Desktop client for jellyfin
      jellyfin-media-player
    ];
  };
}
