{
  config,
  lib,
  ...
}:

{
  options.jellyfin = {
    enable = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          "local"
          "public"
        ]
      );
      default = null;
      description = "How Jellyfin is exposed. null disables it, local restricts to tailnet/LAN, public additionally exposes via the server's public domain.";
    };
    mediaPath = lib.mkOption {
      type = lib.types.path;
      default = "/data/media";
      description = "Host path to the media library";
    };
  };

  config = lib.mkIf (config.jellyfin.enable != null) {

    # Enable jellyfin service
    services.jellyfin = {
      enable = true;
      configDir = "/var/lib/jellyfin/config";
      dataDir = "/var/lib/jellyfin/data";
      cacheDir = "/var/lib/jellyfin/cache";
    };

    # Allow access to the same directories as the arrstack group
    users.users.jellyfin.extraGroups = [
      "render"
      "video"
      "arrstack"
    ];

    # Media path — ensure it exists (mediaDir option handles Jellyfin's access,
    # but the directory itself still needs to be present on the host)
    systemd.tmpfiles.rules = [
      "d ${config.jellyfin.mediaPath} 1777 root root -"
    ];

    # Expose jellyfin via caddy
    caddy.services.jellyfin = {
      port = 8096;
      public = config.jellyfin.enable == "public";
    };

    # Monitor jellyfin via uptime-kuma
    uptime-kuma.monitors.jellyfin.port = 8096;

    # Monitor jellyfin via crowdsec
    crowdsec.collections = [ "LePresidente/jellyfin" ];
    crowdsec.acquisitions.jellyfin = {
      journalmatch = "_SYSTEMD_UNIT=jellyfin.service";
      type = "jellyfin";
    };

    # Create jellyfin entry for homepage
    homepage.services.Jellyfin = {
      icon = "jellyfin.png";
      href =
        if config.jellyfin.enable == "public" then
          "https://jellyfin.${config.server.publicDomain}"
        else
          "https://jellyfin.${config.server.domain}";
      description = "Media server";
      ping = "http://127.0.0.1:8096";
      widget = {
        type = "jellyfin";
        url = "http://127.0.0.1:8096";
        key = "{{HOMEPAGE_VAR_JELLYFIN_KEY}}";
        version = 1;
        enableBlocks = true;
        enableNowPlaying = true;
        enableUser = true;
        enableMediaControl = true;
        showEpisodeNumber = true;
        expandOneStreamToTwoRows = false;
      };
    };
  };
}
