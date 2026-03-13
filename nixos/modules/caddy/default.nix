{ config, lib, pkgs, ... }:

{
  options.caddy = {
    enable = lib.mkEnableOption "caddy";
    internalTLS = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Use Caddy's internal CA instead of Let's Encrypt. Use for local/Tailscale-only domains.";
    };
    services = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          port = lib.mkOption {
            type = lib.types.port;
            description = "Port the service listens on";
          };
          tls = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Whether the backend service uses HTTPS internally";
          };
        };
      });
      default = {};
      description = "Services to expose via reverse proxy";
    };
  };

  config = lib.mkIf config.caddy.enable {

    # Enable caddy, a reverse proxy that allows access to services via subdomains
    services.caddy = {
      enable = true;
      virtualHosts = lib.mapAttrs' (name: svc: {
        name = "${name}.${config.server.domain}";
        value = {
          extraConfig = ''
            ${lib.optionalString config.caddy.internalTLS "tls internal"}
            reverse_proxy ${if svc.tls then "https" else "http"}://localhost:${toString svc.port} {
              ${lib.optionalString svc.tls ''
                transport http {
                  tls_insecure_skip_verify
                }
              ''}
            }
          '';
        };
      }) config.caddy.services;
    };

    # Allow HTTP and HTTPS traffic through the firewall
    networking.firewall.allowedTCPPorts = [ 80 443 ];

    # certutil is required to install internal root cert when using tls internal
    # Without it, certificate generation fails silently.
    systemd.services.caddy.path = [ pkgs.nssTools ];
    environment.systemPackages = with pkgs; [
      nssTools
    ];
  };
}
