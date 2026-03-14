{ config, lib, pkgs, ... }:

{
  options.adguard.enable = lib.mkEnableOption "adguard";

  config = lib.mkIf config.adguard.enable {

    # Enable adguard, a DNS that also blocks adverts
    services.adguardhome = {
      enable = true;
      openFirewall = true;
      port = 3000;
      mutableSettings = true;
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

    # Patch AdGuard's mutable config with the admin password before it starts.
    # Only writes users if they aren't already present, avoiding clobbering
    # any changes AdGuard has written back to its own config file.
    age.secrets.adguard-key.mode = "0444";
    systemd.services.adguardhome.preStart = lib.mkIf (builtins.hasAttr "adguard-key" config.age.secrets) (
      let
        adguardConfig = "/var/lib/AdGuardHome/AdGuardHome.yaml";
        secretPath = config.age.secrets.adguard-key.path;
      in
      ''
        if [ -f ${adguardConfig} ] && ! ${pkgs.gnugrep}/bin/grep -q "^users:" ${adguardConfig}; then
          hash=$(cat ${secretPath})
          echo "users:" >> ${adguardConfig}
          echo "  - name: admin" >> ${adguardConfig}
          echo "    password: $hash" >> ${adguardConfig}
        fi
      ''
    );

    # Expose AdGuard's web ui via caddy
    caddy.services.adguard = { port = 3000; };
  };
}
