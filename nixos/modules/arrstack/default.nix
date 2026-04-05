{ config, lib, ... }:

{
  options.arrstack = {
    enable = lib.mkEnableOption "arrstack";

    sonarr = lib.mkEnableOption "sonarr (TV shows)" // { default = true; };
    radarr = lib.mkEnableOption "radarr (movies)" // { default = true; };
    prowlarr = lib.mkEnableOption "prowlarr (indexer manager)" // { default = true; };
    flaresolverr = lib.mkEnableOption "flaresolverr (Cloudflare bypass)" // { default = true; };
    configarr = lib.mkEnableOption "configarr (TRaSH Guide sync)" // { default = true; };
    qbittorrent = lib.mkEnableOption "qbittorrent (torrents with VPN)" // { default = true; };

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

    # Dedicated user for rootless Podman
    # All containers use PUID=991 which maps to the same host UID,
    # this is required to create hardlinks between files and save space
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
    ]
    ++ lib.optionals config.arrstack.configarr [
      "d /var/lib/arrstack/configarr 0755 arrstack arrstack -"
      "d /var/lib/arrstack/configarr/repos 0755 arrstack arrstack -"
    ]
    ++ lib.optionals config.arrstack.qbittorrent [
      "d /data/torrents 1777 root root -"
      "d /data/torrents/complete 1777 root root -"
      "d /data/torrents/incomplete 1777 root root -"
      "d /var/lib/arrstack/qbittorrent 0700 arrstack arrstack -"
      "d /var/lib/arrstack/qbittorrent/config 0700 arrstack arrstack -"
      # Inner dirs owned by the mapped container UID (232062) for atomic writes
      "d /var/lib/arrstack/qbittorrent/config/qBittorrent 0755 232062 232062 -"
      "d /var/lib/arrstack/qbittorrent/config/qBittorrent/BT_backup 0755 232062 232062 -"
    ];

    # Secrets must be world-readable so the rootless container can access them
    age.secrets = lib.mkMerge [
      (lib.mkIf (config.arrstack.configarr && config.agenix.secrets != null && builtins.pathExists "${config.agenix.secrets}/configarr-secrets.age") {
        configarr-secrets.mode = "0444";
      })
      (lib.mkIf config.arrstack.qbittorrent {
        gluetun-addresses.mode = "0444";
        gluetun-id.mode        = "0444";
        gluetun-key.mode       = "0444";
        qbittorrent-key.mode   = "0444";
      })
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

      # Seed qBittorrent.conf on first start only — runtime changes are preserved.
      # To re-seed after updating qBittorrent.conf:
      #   sudo rm /var/lib/arrstack/qbittorrent/config/qBittorrent/qBittorrent.conf
      #   sudo systemctl restart podman-qbittorrent
      (lib.mkIf config.arrstack.qbittorrent {
        podman-qbittorrent = {
          # Ensure gluetun container is started before qbittorrent (dependsOn
          # in the OCI config handles container ordering, but we also need the
          # VPN to actually be established before qbittorrent binds to the
          # network interface — otherwise DHT finds 0 peers on boot).
          after    = [ "podman-gluetun.service" ];
          requires = [ "podman-gluetun.service" ];
          serviceConfig.PermissionsStartOnly = true;
          preStart =
            let
              cfg = "/var/lib/arrstack/qbittorrent/config/qBittorrent/qBittorrent.conf";
              secretPath = config.age.secrets.qbittorrent-key.path;
            in ''
              # Wait up to 120 s for Gluetun's VPN to be healthy
              echo "Waiting for Gluetun VPN to be healthy..."
              _vpn_ready=0
              for _i in $(seq 60); do
                if runuser -u arrstack -- ${config.virtualisation.podman.package}/bin/podman exec gluetun /gluetun-entrypoint healthcheck 2>/dev/null; then
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
      (lib.mkIf (config.arrstack.configarr && config.agenix.secrets != null && builtins.pathExists "${config.agenix.secrets}/configarr-secrets.age") {
        configarr = {
          description = "configarr: sync TRaSH Guide configurations to Sonarr/Radarr";
          after = [ "arrstack-network.service" "network-online.target" ]
            ++ lib.optionals config.arrstack.sonarr [ "podman-sonarr.service" ]
            ++ lib.optionals config.arrstack.radarr [ "podman-radarr.service" ];
          wants = [ "network-online.target" ];
          requires = [ "arrstack-network.service" ];
          serviceConfig = {
            Type = "oneshot";
            User = "arrstack";
            StandardOutput = "journal";
            StandardError = "journal";
            ExecStart = "${config.virtualisation.podman.package}/bin/podman run --rm"
              + " --name=configarr --network=arrstack --pull=newer --log-driver=journald"
              + " -e CONFIG_LOCATION=/app/config.yml"
              + " -e SECRETS_LOCATION=/app/secrets.yml"
              + " -v ${./configarr.yml}:/app/config.yml:ro"
              + " -v ${config.age.secrets.configarr-secrets.path}:/app/secrets.yml:ro"
              + " -v /var/lib/arrstack/configarr/repos:/app/repos"
              + " ghcr.io/raydak-labs/configarr:latest";
          };
        };
      })
    ];

    # Routinely sync *arr stack customisations
    systemd.timers = lib.mkIf (config.arrstack.configarr && config.agenix.secrets != null && builtins.pathExists "${config.agenix.secrets}/configarr-secrets.age") {
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
            # Single /data mount so Sonarr can hardlink from
            # /data/torrents (qBittorrent) to /data/media (library).
            "/data:/data"
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
            # Single /data mount so Radarr can hardlink from
            # /data/torrents (qBittorrent) to /data/media (library).
            "/data:/data"
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
            # Allow access to local network even through the VPN
            FIREWALL_OUTBOUND_SUBNETS = "192.168.1.0/24";
          };
          environmentFiles = [
            config.age.secrets.gluetun-addresses.path
            config.age.secrets.gluetun-id.path
            config.age.secrets.gluetun-key.path
          ];
          ports = [
            "127.0.0.1:8090:8090"
            "${config.server.ip}:8090:8090"
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
      (lib.mkIf config.arrstack.prowlarr    { prowlarr    = { port = 9696; }; })
      (lib.mkIf config.arrstack.sonarr      { sonarr      = { port = 8989; }; })
      (lib.mkIf config.arrstack.radarr      { radarr      = { port = 7878; }; })
      (lib.mkIf config.arrstack.qbittorrent { qbittorrent = { port = 8090; }; })
    ];

    # Monitor arrstack service availability via uptime-kuma
    uptime-kuma.monitors = lib.mkMerge [
      (lib.mkIf config.arrstack.prowlarr    { prowlarr.port    = 9696; })
      (lib.mkIf config.arrstack.sonarr      { sonarr.port      = 8989; })
      (lib.mkIf config.arrstack.radarr      { radarr.port      = 7878; })
      (lib.mkIf config.arrstack.qbittorrent {
        gluetun = { type = "port"; port = 8000; };
        qbittorrent.port = 8090;
      })
    ];
  };
}
