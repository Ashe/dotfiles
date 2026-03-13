{ config, lib, ... }:

{
  options.cockpit.enable = lib.mkEnableOption "cockpit";
  config = lib.mkIf config.cockpit.enable {
    services.cockpit = {
      enable = true;
      openFirewall = true;
      port = 9090;
    };
  };
}
