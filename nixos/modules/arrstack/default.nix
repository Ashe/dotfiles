{
  config,
  lib,
  pkgs,
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
    flaresolverr = lib.mkEnableOption "flaresolverr (Cloudflare bypass)" // {
      default = true;
    };
    configarr = lib.mkEnableOption "configarr (TRaSH Guide sync)" // {
      default = true;
    };
    qbittorrent = lib.mkEnableOption "qbittorrent (torrents with VPN)" // {
      default = true;
    };

    vpnProvider = lib.mkOption {
      type = lib.types.str;
      default = "mullvad";
      description = ''
        VPN provider for Gluetun.
        See https://github.com/qdm12/gluetun-wiki for supported providers.
      '';
    };
  };

  config = lib.mkIf config.arrstack.enable {

    # Define a shared user and group for modules that access the same filesystem
    users.users.arrstack = {
      isSystemUser = true;
      group = "arrstack";
      home = "/var/lib/arrstack";
      createHome = true;
      subUidRanges = [
        {
          startUid = 231072;
          count = 65536;
        }
      ];
      subGidRanges = [
        {
          startGid = 231072;
          count = 65536;
        }
      ];
      linger = true;
    };
    users.groups.arrstack = { };

    # Setup data directories
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
    ++ lib.optionals config.arrstack.flaresolverr [
      "d /var/lib/arrstack/flaresolverr 0777 arrstack arrstack -"
    ]
    ++ lib.optionals config.arrstack.configarr [
      "d /var/lib/arrstack/configarr 0755 arrstack arrstack -"
      "d /var/lib/arrstack/configarr/repos 0755 arrstack arrstack -"
    ]
    ++ lib.optionals config.arrstack.qbittorrent [
      "d /data/torrents 0755 arrstack arrstack -"
      "d /data/torrents/complete 0755 arrstack arrstack -"
      "d /data/torrents/incomplete 0755 arrstack arrstack -"
      "d /var/lib/arrstack/qbittorrent 0700 arrstack arrstack -"
      "d /var/lib/arrstack/qbittorrent/config 0700 arrstack arrstack -"
      # Inner dirs owned by the mapped container UID (232062) for atomic writes
      "d /var/lib/arrstack/qbittorrent/config/qBittorrent 0755 232062 232062 -"
      "d /var/lib/arrstack/qbittorrent/config/qBittorrent/BT_backup 0755 232062 232062 -"
    ];

    # Ensure configarr and qbittorrent secrets are world-readable
    age.secrets = lib.mkMerge [
      (lib.mkIf
        (
          config.arrstack.configarr
          && config.agenix.secrets != null
          && builtins.pathExists "${config.agenix.secrets}/configarr-secrets.age"
        )
        {
          configarr-secrets.mode = "0444";
        }
      )
      (lib.mkIf config.arrstack.qbittorrent {
        gluetun-addresses.mode = "0444";
        gluetun-id.mode = "0444";
        gluetun-key.mode = "0444";
        qbittorrent-key.mode = "0444";
      })
    ];

    # Sonarr — TV show management and automatic downloading
    services.sonarr = lib.mkIf config.arrstack.sonarr {
      enable = true;
      user = "arrstack";
      group = "arrstack";
      dataDir = "/var/lib/arrstack/sonarr";
    };

    # Radarr — movie management and automatic downloading
    services.radarr = lib.mkIf config.arrstack.radarr {
      enable = true;
      user = "arrstack";
      group = "arrstack";
      dataDir = "/var/lib/arrstack/radarr";
    };

    # Prowlarr — indexer manager that syncs indexers to Sonarr/Radarr
    services.prowlarr = lib.mkIf config.arrstack.prowlarr {
      enable = true;
    };

    systemd.services = lib.mkMerge [

      # Disable PrivateUsers for sonarr and radarr
      # PrivateUsers breaks hardlinks with qbittorrent container files (UID 991)
      # because from inside the namespace, those files appear to be owned by an
      # unmapped foreign UID. All other hardening options remain intact.
      (lib.mkIf config.arrstack.sonarr {
        sonarr.serviceConfig.PrivateUsers = lib.mkForce false;
      })

      (lib.mkIf config.arrstack.radarr {
        radarr.serviceConfig.PrivateUsers = lib.mkForce false;
      })

      # Create shared podman network for containers
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

      # Flaresolverr starts after the network is ready
      (lib.mkIf config.arrstack.flaresolverr {
        podman-flaresolverr.after = [ "arrstack-network.service" ];
        podman-flaresolverr.requires = [ "arrstack-network.service" ];
      })

      # Seed qBittorrent.conf on first start only — runtime changes are preserved
      # To re-seed after updating qBittorrent.conf:
      #   sudo rm /var/lib/arrstack/qbittorrent/config/qBittorrent/qBittorrent.conf
      #   sudo systemctl restart podman-qbittorrent
      (lib.mkIf config.arrstack.qbittorrent {
        podman-qbittorrent = {
          # Ensure gluetun container is started before qbittorrent (dependsOn
          # in the OCI config handles container ordering, but we also need the
          # VPN to actually be established before qbittorrent binds to the
          # network interface — otherwise DHT finds 0 peers on boot).
          after = [ "podman-gluetun.service" ];
          requires = [ "podman-gluetun.service" ];
          serviceConfig.PermissionsStartOnly = true;
          preStart =
            let
              cfg = "/var/lib/arrstack/qbittorrent/config/qBittorrent/qBittorrent.conf";
              secretPath = config.age.secrets.qbittorrent-key.path;
            in
            ''
              # Wait up to 120 s for Gluetun's VPN to be healthy
              echo "Waiting for Gluetun VPN to be healthy..."
              _vpn_ready=0
              for _i in $(seq 60); do
                if ${pkgs.curl}/bin/curl -sf http://127.0.0.1:8000/v1/publicip/ip; then
                  _vpn_ready=1
                  break
                fi
                echo "Gluetun not ready yet, retrying..."
                sleep 2
              done
              if [ "$_vpn_ready" = "1" ]; then
                echo "Gluetun VPN is healthy, starting qBittorrent"
              else
                echo "Warning: Gluetun VPN did not become healthy within 120s, starting qBittorrent anyway"
              fi

              if [ ! -f ${cfg} ]; then
                cp ${./qBittorrent.conf} ${cfg}
                cat ${secretPath} >> ${cfg}
                chown 232062:232062 ${cfg}
                chmod 600 ${cfg}
              elif ! grep -q "WebUI\\\\Password_PBKDF2" ${cfg}; then
                echo "" >> ${cfg}
                cat ${secretPath} >> ${cfg}
                chown 232062:232062 ${cfg}
              fi
            '';
        };
      })

      # Configarr — one-shot job to sync TRaSH Guide configs to Sonarr/Radarr
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

    # Routinely sync *arr stack customisations
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

    virtualisation.oci-containers.containers = lib.mkMerge [

      # FlareSolverr — proxy that solves Cloudflare challenges for Prowlarr
      (lib.mkIf config.arrstack.flaresolverr {
        flaresolverr = {
          image = "ghcr.io/flaresolverr/flaresolverr:latest";
          ports = [ "127.0.0.1:8191:8191" ];
          extraOptions = [
            "--pull=newer"
            "--network=arrstack"
            "--user=0:0"
          ];
          podman.user = "arrstack";
        };
      })

      # Gluetun — VPN kill switch; all qBittorrent traffic routes through it
      (lib.mkIf config.arrstack.qbittorrent {
        gluetun = {
          image = "docker.io/qmcgaw/gluetun:latest";
          extraOptions = [
            "--pull=newer"
            "--cap-add=NET_ADMIN"
            "--device=/dev/net/tun"
          ];
          environment = {
            VPN_SERVICE_PROVIDER = config.arrstack.vpnProvider;
            VPN_TYPE = "wireguard";
            HTTPPROXY = "off";
            SHADOWSOCKS = "off";
            HTTP_CONTROL_SERVER_AUTH_DEFAULT_ROLE = "{\"auth\":\"none\"}";
            # Allow access to local network even through the VPN
            FIREWALL_OUTBOUND_SUBNETS = "192.168.1.0/24";
          };
          environmentFiles = [
            config.age.secrets.gluetun-addresses.path
            config.age.secrets.gluetun-id.path
            config.age.secrets.gluetun-key.path
          ];
          ports = [
            # WebUI accessible only via Caddy on localhost
            "127.0.0.1:8090:8090"
            # HTTP control server — used for VPN status polling
            "127.0.0.1:8000:8000"
          ];
          podman.user = "arrstack";
        };

        # qBittorrent — torrent client, network traffic via Gluetun VPN
        qbittorrent = {
          image = "docker.io/linuxserver/qbittorrent:latest";
          extraOptions = [
            "--pull=newer"
            "--network=container:gluetun"
          ];
          environment = {
            PUID = "991";
            PGID = "991";
            WEBUI_PORT = "8090";
          };
          volumes = [
            "/var/lib/arrstack/qbittorrent/config:/config"
            "/data:/data"
          ];
          dependsOn = [ "gluetun" ];
          podman.user = "arrstack";
        };
      })
    ];

    # Expose web UIs via Caddy (local only)
    caddy.services = lib.mkMerge [
      (lib.mkIf config.arrstack.prowlarr { prowlarr.port = 9696; })
      (lib.mkIf config.arrstack.sonarr { sonarr.port = 8989; })
      (lib.mkIf config.arrstack.radarr { radarr.port = 7878; })
      (lib.mkIf config.arrstack.qbittorrent { qbittorrent.port = 8090; })
    ];

    # Monitor arrstack service availability via uptime-kuma
    uptime-kuma.monitors = lib.mkMerge [
      (lib.mkIf config.arrstack.prowlarr { prowlarr.port = 9696; })
      (lib.mkIf config.arrstack.sonarr { sonarr.port = 8989; })
      (lib.mkIf config.arrstack.radarr { radarr.port = 7878; })
      (lib.mkIf config.arrstack.qbittorrent {
        gluetun = {
          type = "http";
          port = 8000;
          path = "/v1/publicip/ip";
        };
        qbittorrent.port = 8090;
      })
    ];
  };
}
