{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.freshrss = {
    enable = lib.mkEnableOption "freshrss";

    feeds = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.listOf (
          lib.types.submodule {
            options = {
              name = lib.mkOption {
                type = lib.types.str;
                description = "Display name for the feed in FreshRSS.";
              };
              url = lib.mkOption {
                type = lib.types.str;
                description = "RSS/Atom feed URL.";
              };
            };
          }
        )
      );
      default = import ./feeds.nix;
      defaultText = lib.literalExpression "import ./feeds.nix";
      description = ''
        Feeds to declaratively seed on first deploy, grouped by category.
        Defaults to ./feeds.nix; override per-server to use a different list.
        To redeploy the seed, do:
          rm /var/lib/freshrss/data/.feeds-seeded
          systemctl restart freshrss-seed-feeds.service
      '';
    };
  };

  config = lib.mkIf config.freshrss.enable {

    users.users.freshrss = {
      isSystemUser = true;
      group = "freshrss";
      home = "/var/lib/freshrss";
      createHome = true;
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
      linger = true;
    };
    users.groups.freshrss = { };

    virtualisation.podman = {
      enable = true;
      autoPrune.enable = true;
    };

    virtualisation.oci-containers.backend = "podman";
    virtualisation.oci-containers.containers.freshrss = {
      image = "docker.io/freshrss/freshrss:latest";
      ports = [ "127.0.0.1:8088:80" ];
      volumes = [
        "/var/lib/freshrss/data:/var/www/FreshRSS/data"
        "/var/lib/freshrss/extensions:/var/www/FreshRSS/extensions"
      ];
      environment = {
        TZ = "Europe/London";
        CRON_MIN = "13,43";
        TRUSTED_PROXY = "127.0.0.1/8";
        # FRESHRSS_INSTALL and FRESHRSS_USER are only consumed on the very
        # first run (when data/config.php doesn't exist yet). Safe to leave
        # declared permanently — subsequent boots ignore them.
        FRESHRSS_INSTALL = lib.concatStringsSep " " [
          "--api-enabled"
          "--auth-type form"
          "--base-url https://${config.server.domain}"
          "--default-user admin"
          "--language en"
        ];
      };
      environmentFiles = lib.optional (
        config.agenix.secrets != null && builtins.pathExists "${config.agenix.secrets}/freshrss-secrets.age"
      ) config.age.secrets.freshrss-secrets.path;
      extraOptions = [ "--pull=newer" ];
      podman.user = "freshrss";
    };

    # freshrss-secrets.age should export:
    # FRESHRSS_USER=--user admin --password <pass> --api-password <api-pass>
    age.secrets.freshrss-secrets =
      lib.mkIf
        (
          config.agenix.secrets != null && builtins.pathExists "${config.agenix.secrets}/freshrss-secrets.age"
        )
        {
          mode = "0440";
          owner = "freshrss";
        };

    # Seed declared feeds via OPML on first deploy only (sentinel guards re-runs).
    # Runs after the container is up and the install has completed.
    systemd.services.freshrss-seed-feeds = lib.mkIf (config.freshrss.feeds != { }) {
      description = "Seed declarative FreshRSS feeds via OPML (once)";
      after = [ "podman-freshrss.service" ];
      requires = [ "podman-freshrss.service" ];
      wantedBy = [ "multi-user.target" ];
      script =
        let
          opmlFile = pkgs.writeText "freshrss-seed.opml" ''
            <?xml version="1.0" encoding="UTF-8"?>
            <opml version="2.0">
              <head><title>Declarative seed feeds</title></head>
              <body>
            ${lib.concatStringsSep "\n" (
              lib.mapAttrsToList (category: feeds: ''
                    <outline text="${category}" title="${category}">
                ${lib.concatStringsSep "\n" (
                  map (feed: ''
                    <outline type="rss" text="${feed.name}" title="${feed.name}" xmlUrl="${feed.url}" />
                  '') feeds
                )}
                    </outline>
              '') config.freshrss.feeds
            )}
              </body>
            </opml>
          '';
        in
        ''
          SENTINEL=/var/lib/freshrss/data/.feeds-seeded
          if [ ! -f "$SENTINEL" ]; then
            echo "Waiting for FreshRSS to be ready..."
            attempt=0
            max_attempts=30
            until ${pkgs.podman}/bin/podman exec freshrss \
              php /var/www/FreshRSS/cli/health.php 2>/dev/null; do
              attempt=$((attempt + 1))
              if [ "$attempt" -ge "$max_attempts" ]; then
                echo "FreshRSS did not become ready after $max_attempts attempts, giving up."
                exit 1
              fi
              echo "Attempt $attempt/$max_attempts: not ready yet, retrying in 2 seconds..."
              sleep 2
            done
            ${pkgs.podman}/bin/podman cp ${opmlFile} freshrss:/tmp/seed.opml
            ${pkgs.podman}/bin/podman exec freshrss \
              php /var/www/FreshRSS/cli/import-for-user.php \
                --user admin \
                --filename /tmp/seed.opml
            ${pkgs.podman}/bin/podman exec freshrss \
            php /var/www/FreshRSS/cli/actualize-user.php \
            --user admin
            touch "$SENTINEL"
            echo "Feeds seeded successfully!"
          else
            echo "Feeds already seeded, skipping."
          fi
        '';
      serviceConfig = {
        Type = "oneshot";
        User = "freshrss";
        RemainAfterExit = true;
      };
    };

    # Ensure the freshrss data directories exist
    systemd.tmpfiles.rules = [
      "d /var/lib/freshrss/data       0750 freshrss freshrss -"
      "d /var/lib/freshrss/extensions 0750 freshrss freshrss -"
    ];

    # Expose freshRSS via caddy
    caddy.services.freshrss.port = 8088;

    # Monitor freshRSS availability via uptime-kuma
    uptime-kuma.monitors.freshrss.port = 8088;
  };
}
