{ config, lib, ... }:

{
  options.cockpit.enable = lib.mkEnableOption "cockpit";
  config = lib.mkIf config.cockpit.enable {

    # Enable cockpit, a control center for monitoring services, logs and resources
    services.cockpit = {
      enable = true;
      openFirewall = true;
      port = 9090;
    };

    # Expose cockpit web ui via caddy
    caddy.services.cockpit = { port = 9090; tls = true; };
  };
}
