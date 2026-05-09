{ config, lib, ... }:

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
      description = "Host path to mount as the media library inside the container";
    };
  };

  config = lib.mkIf (config.jellyfin.enable != null) {

    # Dedicated user for rootless Podman
    users.users.jellyfin = {
      isSystemUser = true;
      group = "jellyfin";
      home = "/var/lib/jellyfin";
      createHome = true;
      # subUidRanges/subGidRanges provide the UID space needed for
      # container user namespace mapping
      subUidRanges = [
        {
          startUid = 100000;
          count = 65536;
        }
      ];
      subGidRanges = [
        {
          startGid = 100000;
          count = 65536;
        }
      ];
      # Persist session after logout
      linger = true;
    };
    users.groups.jellyfin = { };

    # Ensure media path exists on the host and is owned by the jellyfin user
    systemd.tmpfiles.rules = [
      "d ${config.jellyfin.mediaPath} 1777 root root -"
    ];

    virtualisation.podman = {
      enable = true;
      # Clean up unused images/containers periodically
      autoPrune.enable = true;
    };

    virtualisation.oci-containers.backend = "podman";
    virtualisation.oci-containers.containers.jellyfin = {
      image = "docker.io/jellyfin/jellyfin:latest";
      ports = [ "127.0.0.1:8096:8096" ];
      volumes = [
        "/var/lib/jellyfin:/config"
        "${config.jellyfin.mediaPath}:/media:ro"
      ];
      extraOptions = [ "--pull=newer" ];
      # Have a non-root user run podman
      podman.user = "jellyfin";
    };

    # Expose jellyfin via caddy
    caddy.services.jellyfin = {
      port = 8096;
      public = config.jellyfin.enable == "public";
    };

    # Monitor jellyfin availability via uptime-kuma
    uptime-kuma.monitors.jellyfin.port = 8096;

    # Allow crowdsec to monitor jellyfin's logs for threats
    crowdsec.collections = [ "LePresidente/jellyfin" ];
    crowdsec.acquisitions.jellyfin = {
      journalmatch = "_SYSTEMD_UNIT=podman-jellyfin.service";
      type = "jellyfin";
    };
  };
}
