{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.forgejo = {
    enable = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          "local"
          "public"
        ]
      );
      default = null;
    };

    sshPort = lib.mkOption {
      type = lib.types.port;
      default = 2222;
      description = "Port for Forgejo's SSH git access. Avoid 22 to not conflict with the host's own SSH daemon.";
    };

    appName = lib.mkOption {
      type = lib.types.str;
      default = "Forgejo";
      description = "Display name shown in the Forgejo UI and emails.";
    };

    subdomain = lib.mkOption {
      type = lib.types.str;
      default = "forge";
      description = "Subdomain to access forgejo at.";
    };
  };

  config = lib.mkIf (config.forgejo.enable != null) {

    # Native NixOS Forgejo service. Handles its own user, group, state
    # directory, and systemd unit with appropriate sandboxing built in.
    services.forgejo = {
      enable = true;

      # Use SQLite for simplicity; swap to "postgres" if you need scale.
      database.type = "sqlite3";

      settings = {
        DEFAULT.APP_NAME = config.forgejo.appName;

        server =
          let
            domain =
              if config.forgejo.enable == "public" then config.server.publicDomain else config.server.domain;
            forgejoHost = "${config.forgejo.subdomain}.${domain}";
          in
          {
            # Tell Forgejo what domain it lives on so clone URLs are correct
            DOMAIN = "${forgejoHost}";
            ROOT_URL = "https://${forgejoHost}";

            # Bind HTTP to loopback only
            HTTP_ADDR = "127.0.0.1";
            HTTP_PORT = 3030;

            # Allow ssh connections
            SSH_PORT = config.forgejo.sshPort;
          };

        # Disable public registration entirely.
        # New accounts must be created by an admin or via invite links.
        service.DISABLE_REGISTRATION = true;

        # Forgejo Actions (CI runner) disabled by default — opt in
        # deliberately once the instance is stable.
        actions.ENABLED = false;

        log = {
          LEVEL = "Info";
          MODE = "console";
        };
      };
    };

    # Ensure that app.ini is writeable
    systemd.services.forgejo.serviceConfig.ExecStartPre = [
      "+${pkgs.coreutils}/bin/chmod 640 /var/lib/forgejo/custom/conf/app.ini"
    ];

    # Ensure credentials are accessible
    age.secrets.forgejo-credentials.mode = lib.mkIf (
      config.agenix.secrets != null
      && builtins.pathExists "${config.agenix.secrets}/forgejo-credentials.age"
    ) "0444";

    # Create default admin account
    systemd.services.forgejo.preStart =
      lib.mkIf
        (
          config.agenix.secrets != null
          && builtins.pathExists "${config.agenix.secrets}/forgejo-credentials.age"
        )
        (
          lib.mkAfter (
            let
              adminCmd = "${lib.getExe config.services.forgejo.package} admin user";
              credentials = config.age.secrets.forgejo-credentials.path;
              extractKey = key: "$(grep '^${key}=' ${credentials} | cut -d'=' -f2- | tr -d '\n')";
            in
            ''
              ${adminCmd} create --admin \
                  --email ${extractKey "EMAIL"} \
                  --username ${extractKey "USER"} \
                  --password ${extractKey "PASSWORD"} \
                  || true
            ''
          )
        );

    # Expose Forgejo via Caddy
    caddy.services."${config.forgejo.subdomain}" = {
      port = 3030;
      public = config.forgejo.enable == "public";
    };

    # Monitor Forgejo HTTP availability via uptime-kuma
    uptime-kuma.monitors.forgejo.port = 3030;

    # CrowdSec — parse Forgejo's systemd journal for threats.
    # No official Forgejo collection exists; the journald acquisition
    # combined with the Caddy collection covers HTTP-layer attacks.
    crowdsec.acquisitions.forgejo = {
      journalmatch = "_SYSTEMD_UNIT=forgejo.service";
      type = "syslog";
    };

    # Open the SSH port so git+ssh:// clone URLs work.
    # HTTP does not need opening — Caddy handles it on 443.
    networking.firewall.allowedTCPPorts = [ config.forgejo.sshPort ];
  };
}
