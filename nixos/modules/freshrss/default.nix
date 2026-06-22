{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.freshrss = {
    enable = lib.mkEnableOption "freshrss";

    subdomain = lib.mkOption {
      type = lib.types.str;
      default = "rss";
      description = "Subdomain to access FreshRSS at.";
    };

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
          rm /var/lib/freshrss/.feeds-seeded
          systemctl restart freshrss-seed-feeds.service
      '';
    };
  };

  config = lib.mkIf config.freshrss.enable (
    let
      vhost = "${config.freshrss.subdomain}.${config.server.domain}";
      credentialsPresent =
        config.agenix.secrets != null
        && builtins.pathExists "${config.agenix.secrets}/freshrss-secrets.age";
    in
    {

      services.freshrss = {
        enable = true;
        defaultUser = "admin";
        language = "en";
        authType = "form";
        baseUrl = "https://${vhost}";
        webserver = "caddy";
        virtualHost = vhost;
        passwordFile = lib.mkIf credentialsPresent config.age.secrets.freshrss-secrets.path;
      };

      # Ensure credentials are accessible
      age.secrets.freshrss-secrets = lib.mkIf credentialsPresent {
        mode = "0444";
        owner = "freshrss";
        group = "freshrss";
      };

      # Generate OPML from the feeds option
      systemd.services.freshrss-seed-feeds = lib.mkIf (config.freshrss.feeds != { }) {
        description = "Seed declarative FreshRSS feeds via OPML (once)";
        after = [
          "network.target"
          "freshrss-config.service"
        ];
        requires = [
          "freshrss-config.service"
        ];
        wantedBy = [ "multi-user.target" ];
        script =
          let
            php = "${pkgs.php}/bin/php";
            freshrssCli = "${pkgs.freshrss}/cli";
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
            SENTINEL=/var/lib/freshrss/.feeds-seeded
            if [ -f "$SENTINEL" ]; then
              echo "Feeds already seeded, skipping."
              exit 0
            fi

            echo "Importing feeds..."
            ${php} ${freshrssCli}/import-for-user.php --user admin --filename ${opmlFile}

            echo "Updating feed contents..."
            ${php} ${freshrssCli}/actualize-user.php --user admin

            touch "$SENTINEL"
            echo "Feeds seeded successfully!"
          '';
        serviceConfig = {
          Type = "oneshot";
          User = "freshrss";
          Group = "freshrss";
          RemainAfterExit = true;
          Environment = "DATA_PATH=/var/lib/freshrss";
          ReadWritePaths = "/var/lib/freshrss";
          StateDirectory = "freshrss";
        };
      };

      # Ensure sentinel directory is writable
      systemd.tmpfiles.rules = [
        "d /var/lib/freshrss/data 0750 freshrss freshrss -"
      ];

      # Register freshrss with caddy, but since it uses caddy internally,
      # do not create a reverse proxy here
      caddy.services."${config.freshrss.subdomain}".createReverseProxy = false;

      # Create homepage entry for freshRSS
      homepage.services.FreshRSS = {
        icon = "freshrss.png";
        href = "https://${vhost}";
        description = "RSS aggregator";
        ping = "https://${vhost}";
        widget = {
          type = "freshrss";
          url = "https://${vhost}/api/greader.php";
          username = "{{HOMEPAGE_VAR_FRESHRSS_USER}}";
          password = "{{HOMEPAGE_VAR_FRESHRSS_API_PASS}}";
        };
      };
    }
  );
}
