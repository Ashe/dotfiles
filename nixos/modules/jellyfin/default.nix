{ config, lib, ... }:

{
  options.jellyfin.enable = lib.mkEnableOption "jellyfin";
  config = lib.mkIf config.jellyfin.enable {

    # Configure jellyfin, a media server for streaming movies, TV and music
    services.jellyfin = {
      enable = true;
      openFirewall = true;
    };

    # Expose jellyfin via caddy
    caddy.services.jellyfin = { port = 8096; };
  };
}
