{ config, lib, ... }:

{
  options.tailscale = {
    enable = lib.mkEnableOption "tailscale";
    subnetRouter = lib.mkEnableOption "subnet router";
    port = lib.mkOption {
      type = lib.types.port;
      default = config.server.defaultPorts.tailscale;
      description = "UDP port for incoming Tailscale connections.";
    };
  };

  config = lib.mkIf config.tailscale.enable {
    services.tailscale = {
      enable = true;
      port = config.tailscale.port;
      useRoutingFeatures = lib.mkIf config.tailscale.subnetRouter "server";
      extraUpFlags = lib.mkIf config.tailscale.subnetRouter [
        "--advertise-routes=${lib.concatStringsSep "." (lib.take 3 (lib.splitString "." config.server.ip))}.0/24"
      ];
    };

    networking.firewall = {
      trustedInterfaces = [ "tailscale0" ];
      allowedUDPPorts = [ config.tailscale.port ];
    };
  };
}
