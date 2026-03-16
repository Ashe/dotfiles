{ config, lib, ... }:

{
  options.qbittorrent = {
    enable = lib.mkEnableOption "qbittorrent";
    vpnProvider = lib.mkOption {
      type = lib.types.str;
      default = "mullvad";
      description = "VPN provider for Gluetun. See https://github.com/qdm12/gluetun-wiki for supported providers.";
    };
  };

  config = lib.mkIf config.qbittorrent.enable {

    # Dedicated user for rootless Podman
    users.users.qbittorrent = {
      isSystemUser = true;
      uid = 991;
      group = "qbittorrent";
      home = "/var/lib/qbittorrent";
      createHome = true;
      subUidRanges = [{ startUid = 165536; count = 65536; }];
      subGidRanges = [{ startGid = 165536; count = 65536; }];
      linger = true;
    };
    users.groups.qbittorrent = {};

    # Ensure directories exist
    systemd.tmpfiles.rules = [
      # Recursively fix ownership of qbittorrent home
      # Rootless podman creates subdirectories with remapped UIDs on first run
      "Z /var/lib/qbittorrent - qbittorrent qbittorrent -"
      # Downloads
      "d /data/downloads 0755 qbittorrent qbittorrent -"
      "d /data/downloads/complete 0755 qbittorrent qbittorrent -"
      "d /data/downloads/incomplete 0755 qbittorrent qbittorrent -"
      # Media
      "d /data/media/movies 0755 qbittorrent qbittorrent -"
      "d /data/media/shows 0755 qbittorrent qbittorrent -"
      "d /data/media/music 0755 qbittorrent qbittorrent -"
    ];

    # Secrets must be world-readable so the rootless container can access them
    age.secrets.gluetun-addresses.mode = "0444";
    age.secrets.gluetun-id.mode = "0444";
    age.secrets.gluetun-key.mode = "0444";
    age.secrets.qbittorrent-key.mode = "0444";

    # Inject the web UI password before qBittorrent starts.
    # Only writes credentials if the config file doesn't already exist
    systemd.services.podman-qbittorrent = {
      serviceConfig.PermissionsStartOnly = true;
      preStart = lib.mkIf (builtins.hasAttr "qbittorrent-key" config.age.secrets)
        (let
          cfg = "/var/lib/qbittorrent/qBittorrent/qBittorrent.conf";
          secretPath = config.age.secrets.qbittorrent-key.path;
        in ''
          if [ ! -f ${cfg} ]; then
            mkdir -p /var/lib/qbittorrent/qBittorrent
            echo "[Preferences]" > ${cfg}
            cat ${secretPath} >> ${cfg}
            chown 166526:166526 ${cfg}
          elif ! grep -q "WebUI\\\\Password_PBKDF2" ${cfg}; then
            echo "" >> ${cfg}
            cat ${secretPath} >> ${cfg}
            chown 166526:166526 ${cfg}
          fi
      '');
    };

    virtualisation.oci-containers.containers = {

      # Configure Gluetun, a VPN kill switch container
      # All outbound traffic from qBittorrent is routed through the VPN
      gluetun = {
        image = "docker.io/qmcgaw/gluetun:latest";
        extraOptions = [
          "--pull=newer"
          "--cap-add=NET_ADMIN"
          "--device=/dev/net/tun"
        ];
        environment = {
          VPN_SERVICE_PROVIDER = config.qbittorrent.vpnProvider;
          VPN_TYPE = "wireguard";
          HTTPPROXY = "off";
          SHADOWSOCKS = "off";
          # Allow access to local network even through the VPN
          FIREWALL_OUTBOUND_SUBNETS = "192.168.1.0/24";
        };
        environmentFiles = lib.optionals
          (builtins.hasAttr "gluetun-addresses" config.age.secrets &&
           builtins.hasAttr "gluetun-id" config.age.secrets &&
           builtins.hasAttr "gluetun-key" config.age.secrets)
          [ config.age.secrets.gluetun-addresses.path
            config.age.secrets.gluetun-id.path
            config.age.secrets.gluetun-key.path
          ];
        # Only the web UI port is exposed — all other traffic goes through the VPN
        ports = [ "127.0.0.1:8090:8090" ];
        podman.user = "qbittorrent";
      };

      # Configure qBittorrent, a downloader running through a VPN
      # If the VPN drops, qBittorrent loses internet access entirely (kill switch).
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
          "/var/lib/qbittorrent:/config"
          "/data/downloads:/downloads"
          "/data/media:/media"
        ];
        dependsOn = [ "gluetun" ];
        podman.user = "qbittorrent";
      };
    };

    # Expose qBittorrent web UI via Caddy (local only)
    caddy.services.qbittorrent = { port = 8090; };
  };
}
