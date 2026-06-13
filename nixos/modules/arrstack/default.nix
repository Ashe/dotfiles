{
  config,
  lib,
  ...
}:

{
  options.arrstack = {
    enable = lib.mkEnableOption "arrstack";

    sonarr = lib.mkEnableOption "sonarr (TV shows)" // {
      default = true;
    };
    radarr = lib.mkEnableOption "radarr (movies)" // {
      default = true;
    };
    prowlarr = lib.mkEnableOption "prowlarr (indexer manager)" // {
      default = true;
    };
    byparr = lib.mkEnableOption "byparr (Cloudflare bypass)" // {
      default = true;
    };
    configarr = lib.mkEnableOption "configarr (TRaSH Guide sync)" // {
      default = true;
    };
  };

  config = lib.mkIf config.arrstack.enable {

    users.users.arrstack = {
      isSystemUser = true;
      uid = 990;
      group = "arrstack";
      home = "/var/lib/arrstack";
      createHome = true;
      extraGroups = [ "qbittorrent" ];
      linger = true;
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
    };

    users.groups.arrstack = {
      gid = 990;
    };

    systemd.tmpfiles.rules = [
      "d /data/media 0755 arrstack arrstack -"
      "d /data/media/movies 0755 arrstack arrstack -"
      "d /data/media/shows 0755 arrstack arrstack -"
      "d /data/media/anime 0755 arrstack arrstack -"
      "d /data/media/music 0755 arrstack arrstack -"
    ]
    ++ lib.optionals config.arrstack.sonarr [
      "d /var/lib/arrstack/sonarr 0750 arrstack arrstack -"
    ]
    ++ lib.optionals config.arrstack.radarr [
      "d /var/lib/arrstack/radarr 0750 arrstack arrstack -"
    ]
    ++ lib.optionals config.arrstack.byparr [
      "d /var/lib/arrstack/byparr 0777 arrstack arrstack -"
    ]
    ++ lib.optionals config.arrstack.configarr [
      "d /var/lib/arrstack/configarr 0755 arrstack arrstack -"
      "d /var/lib/arrstack/configarr/repos 0755 arrstack arrstack -"
    ];

    age.secrets =
      lib.mkIf
        (
          config.arrstack.configarr
          && config.agenix.secrets != null
          && builtins.pathExists "${config.agenix.secrets}/configarr-secrets.age"
        )
        {
          configarr-secrets.mode = "0444";
        };

    services.sonarr = lib.mkIf config.arrstack.sonarr {
      enable = true;
      user = "arrstack";
      group = "arrstack";
      dataDir = "/var/lib/arrstack/sonarr";
    };

    services.radarr = lib.mkIf config.arrstack.radarr {
      enable = true;
      user = "arrstack";
      group = "arrstack";
      dataDir = "/var/lib/arrstack/radarr";
    };

    services.prowlarr = lib.mkIf config.arrstack.prowlarr {
      enable = true;
    };

    systemd.services = lib.mkMerge [

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

      (lib.mkIf config.arrstack.byparr {
        podman-byparr.after = [ "arrstack-network.service" ];
        podman-byparr.requires = [ "arrstack-network.service" ];
      })

      (lib.mkIf
        (
          config.arrstack.configarr
          && config.agenix.secrets != null
          && builtins.pathExists "${config.agenix.secrets}/configarr-secrets.age"
        )
        {
          configarr = {
            description = "configarr: sync TRaSH Guide configurations to Sonarr/Radarr";
            after = [
              "network-online.target"
            ]
            ++ lib.optionals config.arrstack.sonarr [ "sonarr.service" ]
            ++ lib.optionals config.arrstack.radarr [ "radarr.service" ];
            wants = [ "network-online.target" ];
            serviceConfig = {
              Type = "oneshot";
              User = "arrstack";
              StandardOutput = "journal";
              StandardError = "journal";
              ExecStart =
                "${config.virtualisation.podman.package}/bin/podman run --rm"
                + " --name=configarr --network=host --pull=newer --log-driver=journald"
                + " -e CONFIG_LOCATION=/app/config.yml"
                + " -e SECRETS_LOCATION=/app/secrets.yml"
                + " -v ${./configarr.yml}:/app/config.yml:ro"
                + " -v ${config.age.secrets.configarr-secrets.path}:/app/secrets.yml:ro"
                + " -v /var/lib/arrstack/configarr/repos:/app/repos"
                + " ghcr.io/raydak-labs/configarr:latest";
            };
          };
        }
      )
    ];

    systemd.timers =
      lib.mkIf
        (
          config.arrstack.configarr
          && config.agenix.secrets != null
          && builtins.pathExists "${config.agenix.secrets}/configarr-secrets.age"
        )
        {
          configarr = {
            wantedBy = [ "timers.target" ];
            timerConfig = {
              OnBootSec = "5min";
              OnUnitActiveSec = "6h";
              Unit = "configarr.service";
            };
          };
        };

    virtualisation.oci-containers.containers = lib.mkIf config.arrstack.byparr {
      byparr = {
        image = "ghcr.io/thephaseless/byparr:latest";
        ports = [ "127.0.0.1:8191:8191" ];
        extraOptions = [
          "--pull=newer"
          "--network=arrstack"
        ];
        podman.user = "arrstack";
      };
    };

    # Expose services via caddy
    caddy.services = lib.mkMerge [
      (lib.mkIf config.arrstack.prowlarr { prowlarr.port = 9696; })
      (lib.mkIf config.arrstack.sonarr { sonarr.port = 8989; })
      (lib.mkIf config.arrstack.radarr { radarr.port = 7878; })
    ];

    # Monitor services via uptime-kuma
    uptime-kuma.monitors = lib.mkMerge [
      (lib.mkIf config.arrstack.prowlarr { prowlarr.port = 9696; })
      (lib.mkIf config.arrstack.sonarr { sonarr.port = 8989; })
      (lib.mkIf config.arrstack.radarr { radarr.port = 7878; })
      (lib.mkIf config.arrstack.byparr { byparr.port = 8191; })
    ];

    # Create arrstack entries for homepage
    homepage.services = lib.mkMerge [
      (lib.mkIf config.arrstack.prowlarr {
        Prowlarr = {
          icon = "prowlarr.png";
          href = "https://prowlarr.${config.server.domain}";
          description = "Indexer management";
          ping = "http://127.0.0.1:9696";
          widget = {
            type = "prowlarr";
            url = "http://127.0.0.1:9696";
            key = "{{HOMEPAGE_VAR_PROWLARR_KEY}}";
          };
        };
      })
      (lib.mkIf config.arrstack.sonarr {
        Sonarr = {
          icon = "sonarr.png";
          href = "https://sonarr.${config.server.domain}";
          description = "TV show management";
          ping = "http://127.0.0.1:8989";
          widget = {
            type = "sonarr";
            url = "http://127.0.0.1:8989";
            key = "{{HOMEPAGE_VAR_SONARR_KEY}}";
            enableQueue = true;
          };
        };
      })
      (lib.mkIf config.arrstack.radarr {
        Radarr = {
          icon = "radarr.png";
          href = "https://radarr.${config.server.domain}";
          description = "Movie management";
          ping = "http://127.0.0.1:7878";
          widget = {
            type = "radarr";
            url = "http://127.0.0.1:7878";
            key = "{{HOMEPAGE_VAR_RADARR_KEY}}";
          };
        };
      })
      (lib.mkIf config.arrstack.byparr {
        Byparr = {
          icon = "byparr.png";
          description = "Indexer proxy";
          ping = "http://127.0.0.1:8191";
        };
      })
    ];
  };
}
