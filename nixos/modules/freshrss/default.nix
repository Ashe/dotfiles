{
  config,
  lib,
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
          rm /var/lib/freshrss/.feeds-seeded
          systemctl restart freshrss-seed-feeds.service
      '';
    };
  };

  config = lib.mkIf config.freshrss.enable {

    services.freshrss = {
      enable = true;
      defaultUser = "admin";
      language = "en";
      authType = "form";
      baseUrl = "https://${config.server.domain}";
      webserver = "caddy";
      # Required non-null string; the generated vhost is neutralised below.
      virtualHost = "_freshrss-unused";

      passwordFile = lib.mkIf (
        config.agenix.secrets != null && builtins.pathExists "${config.agenix.secrets}/freshrss-secrets.age"
      ) config.age.secrets.freshrss-secrets.path;
    };

    # Ensure credentials are accessible
    age.secrets.freshrss-secrets =
      lib.mkIf
        (
          config.agenix.secrets != null && builtins.pathExists "${config.agenix.secrets}/freshrss-secrets.age"
        )
        {
          mode = "0444";
          owner = "freshrss";
          group = "freshrss";
        };

    # The module creates a Caddy vhost at virtualHost and sets listen.owner = caddy.user.
    # We override the pool to listen on TCP so our caddy abstraction can reach it by port,
    # and we nullify the generated vhost so it doesn't serve anything.
    services.phpfpm.pools.freshrss.settings = {
      "listen" = lib.mkForce "127.0.0.1:8088";
      "listen.owner" = lib.mkForce "";
      "listen.group" = lib.mkForce "";
      "listen.mode" = lib.mkForce "";
    };

    # Neutralise the vhost the module generated — we use caddy.services below instead.
    services.caddy.virtualHosts."_freshrss-unused" = lib.mkForce { };

    # Expose FreshRSS via caddy
    caddy.services.freshrss.port = 8088;

    # Monitor FreshRSS availability via uptime-kuma
    uptime-kuma.monitors.freshrss.port = 8088;

    # Create homepage entry for freshRSS
    homepage.services.FreshRSS = {
      icon = "freshrss.png";
      href = "https://freshrss.${config.server.domain}";
      description = "RSS aggregator";
      ping = "https://127.0.0.1:8088";
      widget = {
        type = "freshrss";
        url = "https://127.0.0.1:8088/api/greader.php";
        username = "{{HOMEPAGE_VAR_FRESHRSS_USER}}";
        password = "{{HOMEPAGE_VAR_FRESHRSS_API_PASS}}";
      };
    };
  };
}
