{ config, lib, pkgs, ... }:

{
  options.ddclient = lib.mkOption {
    default     = {};
    description = "Dynamic DNS providers, keyed by service name (e.g. \"porkbun\").";
    type = lib.types.attrsOf (lib.types.submodule ({ name, ... }: {
      options = {
        enable = lib.mkEnableOption "${name} dynamic DNS via ddclient";

        protocol = lib.mkOption {
          type        = lib.types.str;
          default     = name;
          description = "ddclient protocol name. Defaults to the service name.";
        };

        domain = lib.mkOption {
          type        = lib.types.nullOr lib.types.str;
          default     = null;
          description = "Root domain to update. Defaults to server.publicDomain.";
        };

        subdomains = lib.mkOption {
          type        = lib.types.nullOr (lib.types.listOf lib.types.str);
          default     = null;
          description = "Subdomains to update. Defaults to publicly-exposed caddy services.";
        };
      };
    }));
  };

  config = let
    # Resolve effective values and filter to providers that are enabled and have a credential file
    # Credential file: ddclient-<name>.age, containing ddclient config syntax credentials e.g.:
    #   apikey=pk1_...
    #   secretapikey=sk1_...
    active = lib.mapAttrs (name: svc: svc // {
      domain     = if svc.domain     != null then svc.domain
                   else config.server.publicDomain;
      subdomains = if svc.subdomains != null then svc.subdomains
                   else lib.attrNames (lib.filterAttrs (_: s: s.public) config.caddy.services);
    }) (lib.filterAttrs (name: svc:
      svc.enable
      && config.agenix.secrets != null
      && builtins.pathExists "${config.agenix.secrets}/ddclient-${name}.age"
    ) config.ddclient);

  in lib.mkIf (active != {}) {

    # Mode 0444 so the DynamicUser service process can read each provider's credential file
    age.secrets = lib.mapAttrs' (name: _:
      lib.nameValuePair "ddclient-${name}" { mode = "0444"; }
    ) active;

    # Build the ddclient config at runtime by prepending each provider's credential file
    # to its nix-generated config block, then run ddclient once against the result
    systemd.services.ddclient = {
      description = "ddclient — dynamic DNS updater";
      after       = [ "network-online.target" ];
      wants       = [ "network-online.target" ];
      serviceConfig = {
        Type                 = "oneshot";
        RuntimeDirectory     = "ddclient";
        RuntimeDirectoryMode = "0700";
        ExecStart = pkgs.writeShellScript "ddclient-run" (''
          set -euo pipefail
          umask 077
          CONF=/run/ddclient/ddclient.conf
          printf 'usev4=webv4\n\n' > "$CONF"

        '' + lib.concatStringsSep "\n" (lib.mapAttrsToList (name: svc: ''
          cat ${config.age.secrets."ddclient-${name}".path} >> "$CONF"
          printf '\nprotocol=${svc.protocol}\nroot-domain=${svc.domain}\n${
            lib.concatStringsSep "," (map (sub: "${sub}.${svc.domain}") svc.subdomains)
          }\n\n' >> "$CONF"
        '') active) + ''

          ${pkgs.ddclient}/bin/ddclient -file "$CONF" -verbose -foreground -cache /var/cache/ddclient/ddclient.cache
        '');

        DynamicUser             = true;
        CacheDirectory          = "ddclient";
        NoNewPrivileges         = true;
        PrivateDevices          = true;
        PrivateTmp              = true;
        ProtectClock            = true;
        ProtectControlGroups    = true;
        ProtectHome             = true;
        ProtectHostname         = true;
        ProtectKernelLogs       = true;
        ProtectKernelModules    = true;
        ProtectKernelTunables   = true;
        ProtectSystem           = "strict";
        RestrictAddressFamilies = [ "AF_INET" "AF_INET6" ];
        RestrictRealtime        = true;
        RestrictSUIDSGID        = true;
      };
    };

    # Run ddclient shortly after boot and then every 5 minutes to catch IP changes quickly
    systemd.timers.ddclient = {
      description = "ddclient — periodic DNS refresh";
      wantedBy    = [ "timers.target" ];
      timerConfig = {
        OnBootSec       = "1min";
        OnUnitActiveSec = "5min";
        Unit            = "ddclient.service";
      };
    };

    # Tiny HTTP service on localhost:9099 — path is the FQDN to check (e.g. /jellyfin.aas.sh)
    # Returns 200 if the DNS record matches the current public IP, 503 if stale, 404 if unknown.
    systemd.services.ddclient-dns-check = {
      description = "ddclient DNS health check";
      wantedBy    = [ "multi-user.target" ];
      after       = [ "network.target" ];
      serviceConfig = {
        ExecStart =
          let
            validHosts = lib.concatStringsSep " " (lib.concatLists (lib.mapAttrsToList (_: svc:
              map (sub: "${sub}.${svc.domain}") svc.subdomains) active));
            script = pkgs.writeShellScript "ddclient-dns-check" ''
              set -euo pipefail
              read -r _METHOD RAW_PATH _PROTO || true
              HOST="''${RAW_PATH#/}"
              case " ${validHosts} " in
                *" $HOST "*)
                  IP=$(${pkgs.curl}/bin/curl -sf --max-time 5 https://api.ipify.org)
                  DNS=$(${pkgs.dig}/bin/dig +short A "$HOST" | head -1)
                  if [ "$IP" = "$DNS" ]; then
                    printf "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n\r\nOK: $HOST -> $IP\n"
                  else
                    printf "HTTP/1.1 503 Mismatch\r\nContent-Type: text/plain\r\n\r\nMISMATCH: $HOST expected $IP got $DNS\n"
                  fi
                  ;;
                *)
                  printf "HTTP/1.1 404 Not Found\r\nContent-Type: text/plain\r\n\r\nUnknown host: $HOST\n"
                  ;;
              esac
            '';
          in
            "${pkgs.socat}/bin/socat TCP4-LISTEN:9099,bind=127.0.0.1,reuseaddr,fork EXEC:${script}";
        DynamicUser             = true;
        Restart                 = "always";
        RestartSec              = "5s";
        CapabilityBoundingSet   = "";
        LockPersonality         = true;
        NoNewPrivileges         = true;
        PrivateDevices          = true;
        PrivateTmp              = true;
        PrivateUsers            = true;
        ProtectClock            = true;
        ProtectControlGroups    = true;
        ProtectHome             = true;
        ProtectHostname         = true;
        ProtectKernelLogs       = true;
        ProtectKernelModules    = true;
        ProtectKernelTunables   = true;
        ProtectProc             = "invisible";
        ProtectSystem           = "strict";
        RestrictAddressFamilies = [ "AF_INET" "AF_INET6" ];
        RestrictNamespaces      = true;
        RestrictRealtime        = true;
        RestrictSUIDSGID        = true;
        SystemCallArchitectures = "native";
        SystemCallFilter        = [ "@system-service" "~@privileged" "~@resources" ];
      };
    };

    # One monitor per FQDN so each shows up individually in uptime-kuma
    uptime-kuma.monitors = lib.listToAttrs (lib.concatLists (lib.mapAttrsToList (providerName: svc:
      map (sub: lib.nameValuePair "dns-${providerName}-${sub}.${svc.domain}" {
        name = "dns: ${sub}.${svc.domain} (${providerName})";
        port = 9099;
        path = "/${sub}.${svc.domain}";
      }) svc.subdomains
    ) active));
  };
}
