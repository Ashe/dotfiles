{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.caddy = {
    enable = lib.mkEnableOption "caddy";
    services = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            host = lib.mkOption {
              type = lib.types.str;
              default = "127.0.0.1";
              description = "Host/IP the backend service listens on. Defaults to localhost.";
            };
            port = lib.mkOption {
              type = lib.types.port;
              description = "Port the service listens on";
            };
            backendProtocol = lib.mkOption {
              type = lib.types.enum [
                "http"
                "https"
              ];
              default = "http";
              description = "Protocol the backend service speaks. Most services use http. Use https for services like Cockpit that only accept HTTPS connections.";
            };
            public = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Whether this service is exposed publicly via the external domain";
            };
          };
        }
      );
      default = { };
    };
  };

  config = lib.mkIf config.caddy.enable {

    # Enable caddy, a reverse proxy that allows access to services via subdomains
    services.caddy =
      let

        # Generate a vhost config for a given service and domain
        # Also log all requests as JSON so CrowdSec can read them via journald
        mkVhost =
          {
            name,
            svc,
            domain,
            tls,
          }:
          lib.nameValuePair "${name}.${domain}" {
            extraConfig = ''
              ${lib.optionalString tls "tls internal"}
              log {
                output stdout
                format json
              }
              reverse_proxy ${svc.backendProtocol}://${svc.host}:${toString svc.port} {
                ${lib.optionalString (svc.backendProtocol == "https") ''
                  transport http {
                    tls_insecure_skip_verify
                  }
                ''}
              }
            '';
          };

        # Hosts that are available by default when caddy is enabled
        defaultHosts = {

          # Expose internal certificate so that caddy can easily be trusted
          "cert.${config.server.domain}" = {
            extraConfig =
              let
                outputFile = "${config.server.domain}-ca.crt";
              in
              ''
                tls internal
                redir / /${outputFile} 302
                route /${outputFile} {
                    header Content-Type application/x-pem-file
                    header Content-Disposition 'attachment; filename="${outputFile}"'
                    rewrite * /root.crt
                    file_server {
                      root /var/lib/caddy/.local/share/caddy/pki/authorities/local/
                    }
                }
                respond / 404
              '';
          };
        };

        # All services get an internal vhost
        localVirtualHosts = lib.mapAttrs' (
          name: svc:
          mkVhost {
            inherit name svc;
            domain = config.server.domain;
            tls = true;
          }
        ) config.caddy.services;

        # Public services also get an external vhost
        publicVirtualHosts = lib.mapAttrs' (
          name: svc:
          mkVhost {
            inherit name svc;
            domain = config.server.publicDomain;
            tls = false;
          }
        ) (lib.filterAttrs (_: svc: svc.public) config.caddy.services);

      in
      {
        enable = true;
        virtualHosts = lib.mkMerge [
          defaultHosts
          localVirtualHosts
          (lib.optionalAttrs (config.server.publicDomain != null) publicVirtualHosts)
        ];
      };

    # Monitor caddy availability via uptime-kuma
    uptime-kuma.monitors.caddy = {
      type = "port";
      port = 2019;
    };

    # Allow HTTP and HTTPS traffic through the firewall
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];

    systemd.services.caddy =
      let
        caddyDataDir = "/var/lib/caddy/.local/share/caddy";
        caddyPkiDir = "${caddyDataDir}/pki/authorities/local";
      in
      {
        # Ensure the PKI directory exists with proper permissions
        preStart = ''
          mkdir -p ${caddyPkiDir}
          chown -R caddy:caddy ${caddyDataDir}
        '';

        # certutil is required to install internal root cert when using tls internal
        # Without it, certificate generation fails silently
        path = [ pkgs.nssTools ];
      };

    # Allow crowdsec to monitor caddy's logs for threats
    crowdsec.collections = [ "crowdsecurity/caddy" ];
    crowdsec.acquisitions.caddy = {
      journalmatch = "_SYSTEMD_UNIT=caddy.service";
      type = "syslog";
    };

    # Create homepage entry for caddy
    homepage.services.Caddy = {
      icon = "caddy.png";
      description = "Reverse proxy";
      ping = "http://127.0.0.1:2019";
      widget = {
        type = "caddy";
        url = "http://127.0.0.1:2019";
      };
    };

    assertions = lib.flatten [
      (lib.mapAttrsToList (name: svc: [
        # Public service but no publicDomain set
        {
          assertion = !svc.public || config.server.publicDomain != null;
          message = ''
            caddy: service '${name}' has public = true, but server.publicDomain is not set.
                Either:
                    A: Set 'server.publicDomain' (see server module), or
                    B: Set 'caddy.services.${name}.public = false'.
          '';
        }

        # Public service but crowdsec not enabled
        {
          assertion = !svc.public || config.crowdsec.enable;
          message = ''
            caddy: service '${name}' has public = true, but crowdsec is not enabled.
                Either:
                    A: Enable crowdsec before exposing '${name}' publicly, or
                    B: Set 'caddy.services.${name}.public = false'.
          '';
        }

        # Public service but no matching crowdsec acquisition registered
        {
          assertion = !svc.public || builtins.hasAttr name config.crowdsec.acquisitions;
          message = ''
            caddy: service '${name}' has public = true, but no crowdsec acquisition named '${name}' exists.
                Either:
                    A: Create the 'crowdsec.acquisitions.${name}' source in the '${name}' module, or
                    B: Set 'caddy.services.${name}.public = false'.
          '';
        }

      ]) config.caddy.services)
    ];
  };
}
