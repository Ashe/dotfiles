{ config, lib, ... }:

{
  options.arrstack = {
    enable = lib.mkEnableOption "arrstack";

    sonarr = lib.mkEnableOption "sonarr (TV shows)" // { default = true; };
    radarr = lib.mkEnableOption "radarr (movies)" // { default = true; };
    prowlarr = lib.mkEnableOption "prowlarr (indexer manager)" // { default = true; };
    flaresolverr = lib.mkEnableOption "flaresolverr (Cloudflare bypass)" // { default = true; };
  };

  config = lib.mkIf config.arrstack.enable {

    # Dedicated user for rootless Podman
    users.users.arrstack = {
      isSystemUser = true;
      group = "arrstack";
      home = "/var/lib/arrstack";
      createHome = true;
      subUidRanges = [{ startUid = 231072; count = 65536; }];
      subGidRanges = [{ startGid = 231072; count = 65536; }];
      linger = true;
    };
    users.groups.arrstack = {};

    # Ensure config directories exist
    systemd.tmpfiles.rules = [
      "Z /var/lib/arrstack - arrstack arrstack -"
      "d /data/media 1777 root root -"
      "d /data/media/movies 1777 root root -"
      "d /data/media/shows 1777 root root -"
      "d /data/media/anime 1777 root root -"
      "d /data/media/music 1777 root root -"
    ]
    ++ lib.optionals config.arrstack.sonarr [
      "d /var/lib/arrstack/sonarr 0777 arrstack arrstack -"
    ]
    ++ lib.optionals config.arrstack.radarr [
      "d /var/lib/arrstack/radarr 0777 arrstack arrstack -"
    ]
    ++ lib.optionals config.arrstack.prowlarr [
      "d /var/lib/arrstack/prowlarr 0777 arrstack arrstack -"
    ]
    ++ lib.optionals config.arrstack.flaresolverr [
      "d /var/lib/arrstack/flaresolverr 0777 arrstack arrstack -"
    ];

    systemd.services = lib.mkMerge [
      # Create shared Podman network so containers can reach each other by name
      {
        arrstack-network = {
          description = "Create arrstack Podman network";
          after = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            User = "arrstack";
            ExecStart = "/bin/sh -c '${config.virtualisation.podman.package}/bin/podman network create arrstack || true'";
          };
        };
      }
      # Ensure all containers start after the network is created
      (lib.mkIf config.arrstack.prowlarr {
        podman-prowlarr.after = [ "arrstack-network.service" ];
        podman-prowlarr.requires = [ "arrstack-network.service" ];
      })
      (lib.mkIf config.arrstack.sonarr {
        podman-sonarr.after = [ "arrstack-network.service" ];
        podman-sonarr.requires = [ "arrstack-network.service" ];
      })
      (lib.mkIf config.arrstack.radarr {
        podman-radarr.after = [ "arrstack-network.service" ];
        podman-radarr.requires = [ "arrstack-network.service" ];
      })
      (lib.mkIf config.arrstack.flaresolverr {
        podman-flaresolverr.after = [ "arrstack-network.service" ];
        podman-flaresolverr.requires = [ "arrstack-network.service" ];
      })
    ];

    virtualisation.oci-containers.containers = lib.mkMerge [

      # Prowlarr — indexer manager that syncs indexers to Sonarr/Radarr
      (lib.mkIf config.arrstack.prowlarr {
        prowlarr = {
          image = "docker.io/linuxserver/prowlarr:latest";
          ports = [ "127.0.0.1:9696:9696" ];
          environment = {
            PUID = "991";
            PGID = "989";
          };
          volumes = [
            "/var/lib/arrstack/prowlarr:/config"
          ];
          extraOptions = [ "--pull=newer" "--network=arrstack" ];
          podman.user = "arrstack";
        };
      })

      # Sonarr — TV show management and automatic downloading
      (lib.mkIf config.arrstack.sonarr {
        sonarr = {
          image = "docker.io/linuxserver/sonarr:latest";
          ports = [ "127.0.0.1:8989:8989" ];
          environment = {
            PUID = "991";
            PGID = "989";
          };
          volumes = [
            "/var/lib/arrstack/sonarr:/config"
            "/data/downloads:/downloads"
            "/data/media/shows:/shows"
            "/data/media/anime:/anime"
          ];
          extraOptions = [ "--pull=newer" "--network=arrstack" ];
          podman.user = "arrstack";
        };
      })

      # Radarr — movie management and automatic downloading
      (lib.mkIf config.arrstack.radarr {
        radarr = {
          image = "docker.io/linuxserver/radarr:latest";
          ports = [ "127.0.0.1:7878:7878" ];
          environment = {
            PUID = "991";
            PGID = "989";
          };
          volumes = [
            "/var/lib/arrstack/radarr:/config"
            "/data/downloads:/downloads"
            "/data/media/movies:/movies"
            "/data/media/anime:/anime"
          ];
          extraOptions = [ "--pull=newer" "--network=arrstack" ];
          podman.user = "arrstack";
        };
      })

      # FlareSolverr — proxy that solves Cloudflare challenges for Prowlarr
      (lib.mkIf config.arrstack.flaresolverr {
        flaresolverr = {
          image = "ghcr.io/flaresolverr/flaresolverr:latest";
          ports = [ "127.0.0.1:8191:8191" ];
          extraOptions = [ "--pull=newer" "--network=arrstack" "--user=0:0" ];
          podman.user = "arrstack";
        };
      })
    ];

    # Expose web UIs via Caddy (local only)
    caddy.services = lib.mkMerge [
      (lib.mkIf config.arrstack.prowlarr { prowlarr = { port = 9696; }; })
      (lib.mkIf config.arrstack.sonarr   { sonarr = { port = 8989; }; })
      (lib.mkIf config.arrstack.radarr   { radarr = { port = 7878; }; })
    ];
  };
}
