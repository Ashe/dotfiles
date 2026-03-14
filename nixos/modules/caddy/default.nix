{ config, lib, pkgs, ... }:

{
  options.caddy = {
    enable = lib.mkEnableOption "caddy";
    services = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          port = lib.mkOption {
            type = lib.types.port;
            description = "Port the service listens on";
          };
          backendProtocol = lib.mkOption {
            type = lib.types.enum [ "http" "https" ];
            default = "http";
            description = "Protocol the backend service speaks. Most services use http. Use https for services like Cockpit that only accept HTTPS connections.";
          };
          public = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Whether this service is exposed publicly via the external domain";
          };
        };
      });
      default = {};
    };
  };

  config = lib.mkIf config.caddy.enable {

    # Enable caddy, a reverse proxy that allows access to services via subdomains
    services.caddy = let

      # Generate a vhost config for a given service and domain
      mkVhost = { name, svc, domain, tls }: lib.nameValuePair
      "${name}.${domain}"
      {
        extraConfig = ''
          ${lib.optionalString tls "tls internal"}
          reverse_proxy ${svc.backendProtocol}://127.0.0.1:${toString svc.port} {
            ${lib.optionalString (svc.backendProtocol == "https") ''
              transport http {
                tls_insecure_skip_verify
              }
            ''}
          }
        '';
      };

      # All services get an internal vhost
      localVirtualHosts = lib.mapAttrs' (name: svc:
        mkVhost { inherit name svc; domain = config.server.domain; tls = true; }
      ) config.caddy.services;

      # Public services also get an external vhost
      publicVirtualHosts = lib.mapAttrs' (name: svc:
        mkVhost { inherit name svc; domain = config.server.publicDomain; tls = false; }
      ) (lib.filterAttrs (_: svc: svc.public) config.caddy.services);

    in {
      enable = true;
      virtualHosts = lib.mkMerge [
        localVirtualHosts
        (lib.optionalAttrs (config.server.publicDomain != null) publicVirtualHosts)
      ];
    };

    # Allow HTTP and HTTPS traffic through the firewall
    networking.firewall.allowedTCPPorts = [ 80 443 ];

    # certutil is required to install internal root cert when using tls internal
    # Without it, certificate generation fails silently
    systemd.services.caddy.path = [ pkgs.nssTools ];

    # Display an error if something tries to make a public virtual host
    # when no public domain has been configured
    assertions =
      lib.mapAttrsToList (name: svc: {
        assertion = !svc.public || config.server.publicDomain != null;
        message = ''
          caddy: service '${name}' has public = true, but server.publicDomain is not set.
              Either:
                  A: Set '${name}.public = false', or
                  B: Set server.publicDomain (see server module).
        '';
      })
    config.caddy.services;
  };
}
