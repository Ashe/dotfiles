{ config, lib, ... }:

{
  options.adguard.enable = lib.mkEnableOption "adguard";

  config = lib.mkIf config.adguard.enable {
    services.adguardhome = {
      enable = true;
      openFirewall = true;
      port = 3000;
      settings = {
        dns = {
          bind_hosts = [ "0.0.0.0" ];
          port = 53;
          upstream_dns = [
            "https://dns.cloudflare.com/dns-query"
            "https://dns.google/dns-query"
          ];
          rewrites = [
            {
              domain = "*.${config.server.domain}";
              answer = config.server.ip;
            }
            {
              domain = config.server.domain;
              answer = config.server.ip;
            }
          ];
        };
      };
    };
  };
}
