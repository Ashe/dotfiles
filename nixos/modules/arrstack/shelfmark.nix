{
  config,
  lib,
  ...
}:

let
  cfg = config.arrstack.shelfmark;
  arrOption = import ./arr-option.nix { inherit lib; };
in
{
  options.arrstack.shelfmark =
    arrOption "Shelfmark" config.server.defaultPorts.arrstack.shelfmark
      "shelfmark";

  config = lib.mkIf (config.arrstack.enable && cfg.enable) {

    systemd.tmpfiles.rules = [
      "d /data/media/books 0755 arrstack arrstack -"
      "d /data/media/audiobooks 0755 arrstack arrstack -"
      "d /var/lib/arrstack/shelfmark 0750 arrstack arrstack -"
    ];

    services.shelfmark = {
      enable = true;
      environment = {
        FLASK_PORT = cfg.port;
        CONFIG_DIR = "/var/lib/arrstack/shelfmark";
        # arrstack's home is read-only in the sandbox, so gunicorn needs a writable HOME
        HOME = "/var/lib/arrstack/shelfmark";

        # Lay files out the way Jellyfin expects: one folder per book, grouped by author
        INGEST_DIR = "/data/media/books";
        FILE_ORGANIZATION = "organize";
        TEMPLATE_ORGANIZE = "{Author}/{Title} ({Year})/{Title}";
        DESTINATION_AUDIOBOOK = "/data/media/audiobooks";
        FILE_ORGANIZATION_AUDIOBOOK = "organize";

        # ReadWritePaths are separate bind mounts, so hardlinks out of /data/torrents fail with EXDEV
        HARDLINK_TORRENTS = "false";
        HARDLINK_TORRENTS_AUDIOBOOK = "false";
      }
      # The nixpkgs package always uses an external bypasser, so point it at byparr
      // lib.optionalAttrs config.arrstack.byparr.enable {
        EXT_BYPASSER_URL = "http://127.0.0.1:${toString config.arrstack.byparr.port}";
      }
      // lib.optionalAttrs config.arrstack.prowlarr.enable {
        PROWLARR_URL = "http://127.0.0.1:${toString config.arrstack.prowlarr.port}";
      }
      // lib.optionalAttrs config.qbittorrent.enable {
        QBITTORRENT_URL = "http://${config.wireguard.namespaceIP}:${toString config.qbittorrent.port}";
        QBITTORRENT_CATEGORY = "books";
      };
    };

    # Run as arrstack rather than a DynamicUser so it can read completed torrents
    # and write into the media library, keeping the rest of the upstream hardening
    systemd.services.shelfmark.serviceConfig = {
      DynamicUser = lib.mkForce false;
      User = "arrstack";
      Group = "arrstack";
      StateDirectory = lib.mkForce "";
      UMask = lib.mkForce "0022";
      ReadWritePaths = [
        "/var/lib/arrstack/shelfmark"
        "/data/media/books"
        "/data/media/audiobooks"
      ];

      # API keys and passwords, e.g. PROWLARR_API_KEY, QBITTORRENT_PASSWORD, HARDCOVER_API_KEY
      EnvironmentFile = lib.mkIf (builtins.hasAttr "shelfmark-secrets" config.age.secrets) config.age.secrets.shelfmark-secrets.path;
    };

    # Expose shelfmark via caddy
    caddy.services.${cfg.subdomain}.port = cfg.port;

    # Monitor shelfmark via uptime-kuma
    uptime-kuma.monitors.shelfmark.port = cfg.port;

    # Create shelfmark entry for homepage
    homepage.services.Shelfmark = {
      icon = "shelfmark.png";
      href = "https://${cfg.subdomain}.${config.server.domain}";
      description = "Book search and downloads";
      ping = "http://127.0.0.1:${toString cfg.port}";
    };
  };
}
