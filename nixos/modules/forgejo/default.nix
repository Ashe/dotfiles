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

    user = lib.mkOption {
      type = lib.types.str;
      default = "git";
      description = ''
        User/Group to own the service.
        Doubles as ssh user user@forgejo.domain.
      '';
    };
  };

  config = lib.mkIf (config.forgejo.enable != null) {

    # Create forgejo user
    users.users.${config.forgejo.user} = {
      isSystemUser = true;
      group = config.forgejo.user;
      home = "/var/lib/forgejo";
      shell = pkgs.bash; # needs a real shell — the forced SSH command runs via `shell -c ...`
    };
    users.groups.${config.forgejo.user} = { };

    # Set up forgejo
    services.forgejo = {
      enable = true;

      # Allow for git@forge.domain ssh
      user = config.forgejo.user;
      group = config.forgejo.user;

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

            # Allow ssh connections using regular ssh port
            START_SSH_SERVER = false;
            SSH_CREATE_AUTHORIZED_KEYS_FILE = false;
            SSH_PORT = config.ssh.local.port;
            SSH_USER = config.forgejo.user;
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

    # Register forgejo with ssh module
    ssh.local.services.${config.forgejo.user} = {
      authorizedKeysCommand =
        let
          exe = lib.getExe config.services.forgejo.package;
          user = config.forgejo.user;
        in
        "${exe} keys -c /var/lib/forgejo/custom/conf/app.ini -e ${user} -u %u -t %t -k %k";
    };

    # Expose Forgejo via Caddy
    caddy.services.${config.forgejo.subdomain} = {
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

    # Create Forgejo entry for homepage
    homepage.services.Forgejo = {
      icon = "forgejo.png";
      description = "Software forge";
      href =
        if config.forgejo.enable == "public" then
          "https://${config.forgejo.subdomain}.${config.server.publicDomain}"
        else
          "https://${config.forgejo.subdomain}.${config.server.domain}";
      ping = "https://127.0.0.1:3030";
    };
  };
}
