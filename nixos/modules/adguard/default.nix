{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.adguard = {
    enable = lib.mkEnableOption "adguard";
    port = lib.mkOption {
      type = lib.types.port;
      default = config.server.defaultPorts.adguard.web;
      description = "Port for the AdGuard Home web UI.";
    };
    dnsPort = lib.mkOption {
      type = lib.types.port;
      default = config.server.defaultPorts.adguard.dns;
      description = "Port for the AdGuard DNS listener.";
    };
    subdomain = lib.mkOption {
      type = lib.types.str;
      default = "adguard";
      description = "Subdomain for the AdGuard Home web UI.";
    };
  };

  config = lib.mkIf config.adguard.enable {

    # Enable adguard, a DNS that also blocks adverts
    services.adguardhome = {
      enable = true;
      openFirewall = false;
      host = "127.0.0.1";
      port = config.adguard.port;
      mutableSettings = true;
      settings = {

        dns = {
          bind_hosts = [ "0.0.0.0" ];
          port = config.adguard.dnsPort;

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
    systemd.services.adguardhome.preStart =
      lib.mkIf (builtins.hasAttr "adguard-key" config.age.secrets)
        (
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

    # Allow LAN devices to query AdGuard DNS
    networking.firewall = {
      allowedTCPPorts = [ config.adguard.dnsPort ];
      allowedUDPPorts = [ config.adguard.dnsPort ];
      extraCommands =
        let
          subnet = "${lib.concatStringsSep "." (lib.take 3 (lib.splitString "." config.server.ip))}.0/24";
        in
        ''
          iptables -A nixos-fw -p udp -s ${subnet} --dport ${toString config.adguard.dnsPort} -j nixos-fw-accept
          iptables -A nixos-fw -p tcp -s ${subnet} --dport ${toString config.adguard.dnsPort} -j nixos-fw-accept
        '';
    };

    # Monitor AdGuard availability via uptime-kuma
    uptime-kuma.monitors.adguard.port = config.adguard.port;

    # Expose AdGuard's web ui via caddy
    caddy.services.${config.adguard.subdomain}.port = config.adguard.port;

    # Create AdGuard entry for homepage
    homepage.services.AdGuard = {
      icon = "adguard-home.png";
      href = "https://${config.adguard.subdomain}.${config.server.domain}";
      description = "DNS & ad blocking";
      ping = "http://127.0.0.1:${toString config.adguard.port}";
      widget = {
        type = "adguard";
        url = "http://127.0.0.1:${toString config.adguard.port}";
        username = "{{HOMEPAGE_VAR_ADGUARD_USER}}";
        password = "{{HOMEPAGE_VAR_ADGUARD_PASS}}";
      };
    };
  };
}
