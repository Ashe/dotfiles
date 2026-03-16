{ config, lib, ... }:

{
  options.cockpit.enable = lib.mkEnableOption "cockpit";
  config = lib.mkIf config.cockpit.enable {

    # Enable cockpit, a control center for monitoring services, logs and resources
    services.cockpit = {
      enable = true;
      openFirewall = false;
      port = 9090;
      settings.WebService = {
        # Only expose cockpit to local connections
        BindAddress = "127.0.0.1";
        # Cockpit rejects websocket connections from origins not in this list.
        # Includes direct access URL and Caddy subdomain if enabled.
        Origins = lib.mkForce (
          let domain = "cockpit.${config.server.domain}";
          in "http://${domain} https://${domain} https://${config.server.domain}:9090"
        );
      };
    };

    # Overwrite default address to restrict access
    systemd.sockets.cockpit = {
      listenStreams = lib.mkForce [ "" "127.0.0.1:${toString config.services.cockpit.port}" ];
    };

    # Expose cockpit web ui via caddy
    caddy.services.cockpit = { port = 9090; backendProtocol = "https"; };
  };
}
