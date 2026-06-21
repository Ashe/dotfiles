{
  config,
  lib,
  ...
}:

{
  options.mealie = {
    enable = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          "local"
          "public"
        ]
      );
      default = null;
    };

    subdomain = lib.mkOption {
      type = lib.types.str;
      default = "mealie";
      description = "Subdomain to access Mealie at.";
    };

    allowSignup = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to allow self-service account creation. Disabled by default; invite admins manually otherwise.";
    };
  };

  config = lib.mkIf (config.mealie.enable != null) {

    # Native NixOS Mealie service. Handles its own user, group, state
    # directory, and systemd unit with appropriate sandboxing built in.
    services.mealie = {
      enable = true;

      listenAddress = "127.0.0.1";
      port = 9925;

      settings = {
        BASE_URL =
          let
            domain =
              if config.mealie.enable == "public" then config.server.publicDomain else config.server.domain;
            mealieHost = "${config.mealie.subdomain}.${domain}";
          in
          "https://${mealieHost}";

        # Disable self-service registration unless explicitly enabled.
        # New accounts must otherwise be created/invited by an admin.
        ALLOW_SIGNUP = if config.mealie.allowSignup then "true" else "false";

        LOG_LEVEL = "info";
      };
    };

    # CrowdSec — parse Mealie's systemd journal for threats.
    # No official Mealie collection exists; the journald acquisition
    # combined with the Caddy collection covers HTTP-layer attacks.
    crowdsec.acquisitions.mealie = {
      journalmatch = "_SYSTEMD_UNIT=mealie.service";
      type = "syslog";
    };

    # Expose Mealie via Caddy
    caddy.services."${config.mealie.subdomain}" = {
      port = config.services.mealie.port;
      public = config.mealie.enable == "public";
    };

    # Monitor Mealie via uptime-kuma
    uptime-kuma.monitors.mealie.port = config.services.mealie.port;

    # Create mealie entry for homepage
    homepage.services.Mealie = {
      icon = "mealie.png";
      description = "Recipe management";
      href =
        if config.mealie.enable == "public" then
          "https://${config.mealie.subdomain}.${config.server.publicDomain}"
        else
          "https://${config.mealie.subdomain}.${config.server.domain}";
      ping = "http://127.0.0.1:${toString config.services.mealie.port}";
      widget = {
        type = "mealie";
        url = "http://127.0.0.1:${toString config.services.mealie.port}";
        key = "{{HOMEPAGE_VAR_MEALIE_API_KEY}}";
        version = 3;
      };
    };
  };
}
