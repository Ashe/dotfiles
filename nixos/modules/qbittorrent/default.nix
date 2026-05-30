{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.qbittorrent = {
    enable = lib.mkEnableOption "qBittorrent torrent client";
  };

  config = lib.mkIf config.qbittorrent.enable {

    # Configure qbittorrent torrent client
    services.qbittorrent = {
      enable = true;
      webuiPort = 8090;
      openFirewall = false;
      serverConfig = {
        BitTorrent = {
          "Session\\DefaultSavePath" = "/data/torrents/complete";
          "Session\\TempPath" = "/data/torrents/incomplete";
          "Session\\TempPathEnabled" = true;
          "Session\\DisableAutoTMMByDefault" = false;
        };
        Preferences = {
          "WebUI\\Address" = "0.0.0.0";
          "WebUI\\Port" = 8090;
        };
      };
    };

    # Ensure download directories exist with correct ownership
    systemd.tmpfiles.rules = [
      "d /data/torrents 0750 qbittorrent qbittorrent -"
      "d /data/torrents/complete 0750 qbittorrent qbittorrent -"
      "d /data/torrents/complete/tv-sonarr 0770 qbittorrent qbittorrent -"
      "d /data/torrents/complete/radarr 0770 qbittorrent qbittorrent -"
      "d /data/torrents/incomplete 0750 qbittorrent qbittorrent -"
      "d /data/torrents/incomplete/tv-sonarr 0770 qbittorrent qbittorrent -"
      "d /data/torrents/incomplete/radarr 0770 qbittorrent qbittorrent -"
    ];

    # Register agenix secret for qbittorrent credentials
    age.secrets =
      lib.mkIf
        (
          config.agenix.secrets != null
          && builtins.pathExists "${config.agenix.secrets}/qbittorrent-credentials.age"
        )
        {
          qbittorrent-credentials = {
            mode = "0400";
            owner = "qbittorrent";
          };
        };

    systemd.services.qbittorrent.serviceConfig = {

      # Ensure downloaded files are owned by torrents group and writeable
      UMask = "0002";

      # Inject credentials after the NixOS module writes its store config, but before qbittorrent starts
      ExecStartPre = [
        (pkgs.writeShellScript "qbittorrent-inject-credentials" ''
          set -euo pipefail

          CREDENTIALS_FILE="${config.age.secrets.qbittorrent-credentials.path}"
          CONFIG_FILE="/var/lib/qBittorrent/qBittorrent/config/qBittorrent.conf"

          # Credentials file format: first line = username, second line = password
          USERNAME=$(sed -n '1p' "$CREDENTIALS_FILE")
          export QB_PASSWORD=$(sed -n '2p' "$CREDENTIALS_FILE")

          # Hash the password using PBKDF2-SHA512 (qBittorrent's format)
          # Produces: @ByteArray(<base64-salt>:<base64-hash>)
          HASHED=$(${pkgs.python3}/bin/python3 << 'EOF'
          import hashlib, os, base64

          password = os.environ["QB_PASSWORD"].encode("utf-8")
          salt = os.urandom(16)
          dk = hashlib.pbkdf2_hmac("sha512", password, salt, 100000)
          salt_b64 = base64.b64encode(salt).decode()
          hash_b64 = base64.b64encode(dk).decode()
          print(f"@ByteArray({salt_b64}:{hash_b64})")
          EOF
          )

          # Inject username and hashed password, replacing if present
          ${pkgs.gnused}/bin/sed -i \
            -e "s|^WebUI\\\\Username=.*|WebUI\\\\Username=$USERNAME|" \
            -e "s|^WebUI\\\\Password_PBKDF2=.*|WebUI\\\\Password_PBKDF2=\"$HASHED\"|" \
            "$CONFIG_FILE"

          # Append keys if they didn't exist
          grep -q "^WebUI\\\\Username=" "$CONFIG_FILE" \
            || ${pkgs.gnused}/bin/sed -i "/^\[Preferences\]/a WebUI\\\\Username=$USERNAME" "$CONFIG_FILE"
          grep -q "^WebUI\\\\Password_PBKDF2=" "$CONFIG_FILE" \
            || ${pkgs.gnused}/bin/sed -i "/^\[Preferences\]/a WebUI\\\\Password_PBKDF2=\"$HASHED\"" "$CONFIG_FILE"
        '')
      ];
    };

    # Register qBittorrent with the wireguard module so it runs inside namespace
    wireguard.services = [ "qbittorrent" ];

    # Expose qbittorrent web-ui via caddy
    caddy.services.qbittorrent = {
      host = config.wireguard.namespaceIP;
      port = 8090;
    };

    # Monitor qbittorrent with uptime-kuma
    uptime-kuma.monitors.qbittorrent = {
      host = config.wireguard.namespaceIP;
      port = 8090;
    };

    # Ensure that wireguard is enabled for this module to function
    assertions = [
      {
        assertion = config.wireguard.enable;
        message = "qbittorrent: requires wireguard.enable = true — qBittorrent must run inside the VPN namespace";
      }
    ];
  };
}
