{ config, lib, ... }:

{
  options.cockpit.enable = lib.mkEnableOption "cockpit";
  config = lib.mkIf config.cockpit.enable {

    # Enable cockpit, a control center for monitoring services, logs and resources
    services.cockpit = {
      enable = true;
      openFirewall = true;
      port = 9090;
      settings.WebService = {
        # Cockpit rejects websocket connections from origins not in this list.
        # Includes direct access URL and Caddy subdomain if enabled.
        Origins = lib.mkForce (
          let domain = "cockpit.${config.server.domain}";
          in "http://${domain} https://${domain} https://${config.server.domain}:9090"
        );
      };
    };

    # Expose cockpit web ui via caddy
    caddy.services.cockpit = { port = 9090; backendProtocol = "https"; };
  };
}
