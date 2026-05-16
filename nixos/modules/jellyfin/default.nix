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

    # ---------------------------------------------------------------------------
    # Native NixOS service
    #
    # The jellyfin module creates the jellyfin user and group automatically.
    # dataDir points at the same /var/lib/jellyfin path the container was
    # already writing to, so existing config, metadata, and the database all
    # carry over with no data migration needed.
    # ---------------------------------------------------------------------------
    services.jellyfin = {
      enable = true;
      configDir = "/var/lib/jellyfin/config";
      dataDir = "/var/lib/jellyfin/data";
      cacheDir = "/var/lib/jellyfin/cache";
    };

    # ---------------------------------------------------------------------------
    # Hardware transcoding (Intel iGPU via VAAPI)
    #
    # renderD128 is present on this host. Adding jellyfin to the render and
    # video groups gives it access to /dev/dri/renderD128 and /dev/dri/card0
    # for hardware-accelerated transcoding via Intel Quick Sync / VAAPI.
    # Enable in Jellyfin: Dashboard → Playback → Transcoding → VA-API.
    # ---------------------------------------------------------------------------
    hardware.graphics.enable = true;

    # Allow access to the same directories as the arrstack group
    users.users.jellyfin.extraGroups = [
      "render"
      "video"
      "arrstack"
    ];

    # ---------------------------------------------------------------------------
    # Media path — ensure it exists (mediaDir option handles Jellyfin's access,
    # but the directory itself still needs to be present on the host)
    # ---------------------------------------------------------------------------
    systemd.tmpfiles.rules = [
      "d ${config.jellyfin.mediaPath} 1777 root root -"
    ];

    # ---------------------------------------------------------------------------
    # Caddy — expose Jellyfin web UI
    # ---------------------------------------------------------------------------
    caddy.services.jellyfin = {
      port = 8096;
      public = config.jellyfin.enable == "public";
    };

    # ---------------------------------------------------------------------------
    # Uptime Kuma — monitor Jellyfin availability
    # ---------------------------------------------------------------------------
    uptime-kuma.monitors.jellyfin.port = 8096;

    # ---------------------------------------------------------------------------
    # Crowdsec — monitor Jellyfin logs for threats
    #
    # Native service logs to journald under jellyfin.service rather than
    # podman-jellyfin.service, so the journalmatch is updated accordingly.
    # ---------------------------------------------------------------------------
    crowdsec.collections = [ "LePresidente/jellyfin" ];
    crowdsec.acquisitions.jellyfin = {
      journalmatch = "_SYSTEMD_UNIT=jellyfin.service";
      type = "jellyfin";
    };
  };
}
