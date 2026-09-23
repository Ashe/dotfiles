{ config, lib, ... }:

{
  options.cockpit = {
    enable = lib.mkEnableOption "cockpit";
    port = lib.mkOption {
      type = lib.types.port;
      default = config.server.defaultPorts.cockpit;
      description = "Port for the Cockpit web UI.";
    };
    subdomain = lib.mkOption {
      type = lib.types.str;
      default = "cockpit";
      description = "Subdomain for the Cockpit web UI.";
    };
  };
  config = lib.mkIf config.cockpit.enable {

    # Enable cockpit, a control center for monitoring services, logs and resources
    services.cockpit = {
      enable = true;
      openFirewall = false;
      port = config.cockpit.port;
      settings.WebService = {
        # Only expose cockpit to local connections
        BindAddress = "127.0.0.1";
        # Cockpit rejects websocket connections from origins not in this list.
        # Includes direct access URL and Caddy subdomain if enabled.
        Origins = lib.mkForce (
          let
            domain = "${config.cockpit.subdomain}.${config.server.domain}";
          in
          "http://${domain} https://${domain} https://${config.server.domain}:${toString config.cockpit.port}"
        );
      };
    };

    # Overwrite default address to restrict access
    systemd.sockets.cockpit = {
      listenStreams = lib.mkForce [
        ""
        "127.0.0.1:${toString config.services.cockpit.port}"
      ];
    };

    # Monitor cockpit availability via uptime-kuma
    uptime-kuma.monitors.cockpit = {
      type = "port";
      port = config.cockpit.port;
    };

    # Expose cockpit web ui via caddy
    caddy.services.${config.cockpit.subdomain} = {
      backendProtocol = "https";
      port = config.cockpit.port;
    };

    # Create cockpit entry for homepage
    homepage.services.Cockpit = {
      icon = "cockpit.png";
      href = "https://${config.cockpit.subdomain}.${config.server.domain}";
      description = "Server management";
      ping = "https://127.0.0.1:${toString config.cockpit.port}";
    };
  };
}
