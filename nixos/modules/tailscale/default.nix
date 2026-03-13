{ config, lib, ... }:

{
  options.tailscale = {
    enable = lib.mkEnableOption "tailscale";
    subnetRoutes = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Subnets to advertise via Tailscale";
    };
  };

  config = lib.mkIf config.tailscale.enable {
    services.tailscale = {
      enable = true;
      useRoutingFeatures = lib.mkIf (config.tailscale.subnetRoutes != []) "server";
      extraUpFlags = lib.mkIf (config.tailscale.subnetRoutes != []) [
        "--advertise-routes=${lib.concatStringsSep "," config.tailscale.subnetRoutes}"
      ];
    };

    networking.firewall = {
      trustedInterfaces = [ "tailscale0" ];
      allowedUDPPorts = [ 41641 ];
    };
  };
}
