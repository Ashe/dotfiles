{ config, lib, ... }:

{
  options.jellyfin.enable = lib.mkEnableOption "jellyfin";
  config = lib.mkIf config.jellyfin.enable {
    services.jellyfin = {
      enable = true;
      openFirewall = true;
    };
  };
}
