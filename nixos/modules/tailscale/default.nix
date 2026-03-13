{ config, lib, ... }:

{
  options.tailscale = {
    enable = lib.mkEnableOption "tailscale";
    subnetRouter = lib.mkEnableOption "subnet router";
  };

  config = lib.mkIf config.tailscale.enable {
    services.tailscale = {
      enable = true;
      useRoutingFeatures = lib.mkIf config.tailscale.subnetRouter "server";
      extraUpFlags = lib.mkIf config.tailscale.subnetRouter [
        "--advertise-routes=${lib.concatStringsSep "." (lib.take 3 (lib.splitString "." config.server.ip))}.0/24"
      ];
    };

    networking.firewall = {
      trustedInterfaces = [ "tailscale0" ];
      allowedUDPPorts = [ 41641 ];
    };
  };
}
