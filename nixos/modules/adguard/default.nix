{ config, lib, ... }:

{
  options.adguard.enable = lib.mkEnableOption "adguard";

  config = lib.mkIf config.adguard.enable {
    services.adguardhome = {
      enable = true;
      openFirewall = true;
      port = 3000;
      mutableSettings = false;
      settings = {
        dns = {
          bind_hosts = [ "0.0.0.0" ];
          port = 53;

          # Bootstrap DNS is used to resolve upstream DNS hostnames themselves
          # Needed because AdGuard can't use Cloudflare/Google as upstream until
          # it knows their IPs
          # Using Quad9's plain DNS servers for bootstrap
          bootstrap_dns = [
            "9.9.9.10"
            "149.112.112.10"
            "2620:fe::10"
            "2620:fe::fe:10"
          ];

          # Upstream DNSkservers used for resolving all queries
          # Using DNS-over-HTTPS for privacy and security.
          upstream_dns = [
            "https://dns.cloudflare.com/dns-query"
            "https://dns.google/dns-query"
          ];
        };
        filtering = {
          rewrites_enabled = true;
          rewrites = [
            {
              domain = "*.${config.server.domain}";
              answer = config.server.ip;
              enabled = true;
            }
            {
              domain = config.server.domain;
              answer = config.server.ip;
              enabled = true;
            }
          ];
        };
      };
    };

    # Expose AdGuard's web ui via caddy
    caddy.services.adguard = { port = 3000; };
  };
}
