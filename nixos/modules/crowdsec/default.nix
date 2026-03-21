{ config, lib, pkgs, ... }:

{
  options.crowdsec = {
    enable = lib.mkEnableOption "crowdsec";

    collections = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = ''
        CrowdSec Hub collections to install declaratively.
        Each service module appends to this list, e.g:
          crowdsec.collections = [ "crowdsecurity/caddy" ];
        All declarations across modules are merged automatically.
        Verify collection names exist first with: cscli hub list -a
      '';
    };

    acquisitions = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          journalmatch = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = ''
              Journald match expression to filter logs for this service.
              e.g. "_SYSTEMD_UNIT=podman-jellyfin.service"
              Use this for containerised services that log to journald.
            '';
          };
          logfiles = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [];
            description = ''
              Host paths to log files to watch.
              Use this as an alternative to journalmatch for services
              that write log files directly.
            '';
          };
          type = lib.mkOption {
            type = lib.types.str;
            description = ''
              Log type label passed to CrowdSec parsers.
              Must match a type known to an installed collection,
              e.g. "jellyfin", "caddy", "sshd".
            '';
          };
        };
      });
      default = {};
      description = ''
        Log acquisition sources, registered by each service module.
        Keyed by service name for convenience — merged into a flat list
        and passed to localConfig.acquisitions internally.

        Example:
          crowdsec.acquisitions.jellyfin = {
            journalmatch = "_SYSTEMD_UNIT=podman-jellyfin.service";
            type = "jellyfin";
          };
      '';
    };
  };

  config = lib.mkIf config.crowdsec.enable {

    # Configure crowdsec, crowdsourced server protection against malicious IPs
    services.crowdsec = {
      enable = true;

      # Install Hub collections declared by service modules.
      hub.collections = config.crowdsec.collections ++ [
        "crowdsecurity/linux"
      ];

      # Collect acquisitions registered by other modules
      localConfig.acquisitions = lib.mapAttrsToList (name: acq:
        lib.optionalAttrs (acq.journalmatch != null) {
          source = "journalctl";
          journalctl_filter = [ acq.journalmatch ];
        }
        // lib.optionalAttrs (acq.logfiles != []) {
          source = "file";
          filenames = acq.logfiles;
        }
        // {
          labels.type = acq.type;
        }
      ) config.crowdsec.acquisitions;


      settings = {
        # Enable the local API for the crowdsec bouncer
        general.api.server.enable = true;
        lapi.credentialsFile = "/var/lib/crowdsec/local_api_credentials.yaml";
        capi.credentialsFile = "/var/lib/crowdsec/online_api_credentials.yaml";
        console = {
          tokenFile = lib.mkIf (builtins.hasAttr "crowdsec-enrollment-key" config.age.secrets)
            config.age.secrets.crowdsec-enrollment-key.path;
          configuration = {
            share_manual_decisions = true;
            share_tainted = true;
            share_custom = true;
            share_context = true;
            console_management = false;
          };
        };
      };
    };

    # Monitor crowdsec availability via uptime-kuma
    uptime-kuma.monitors.crowdsec = { type = "port"; port = 8080; };

    # Enable firewall bouncer to enforce crowdsec ban decisions
    services.crowdsec-firewall-bouncer = lib.mkIf
      (builtins.hasAttr "crowdsec-bouncer-key" config.age.secrets)
    {
      enable = true;
      registerBouncer.enable = false;
      secrets.apiKeyPath = config.age.secrets.crowdsec-bouncer-key.path;
    };

    # Ensure the bouncer is always registered
    systemd.services.crowdsec-bouncer-register = lib.mkIf
        (builtins.hasAttr "crowdsec-bouncer-key" config.age.secrets) {
      description = "Register CrowdSec firewall bouncer";
      after = [ "crowdsec.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "crowdsec-bouncer-register" ''
          if ! /run/current-system/sw/bin/cscli bouncers list | grep -q firewall-bouncer; then
            /run/current-system/sw/bin/cscli bouncers add firewall-bouncer --key $(cat ${config.age.secrets.crowdsec-bouncer-key.path})
          fi
        '';
      };
    };

    # Ensure we are enrolled to crowdsec console
    systemd.services.crowdsec-console-enroll = lib.mkIf
      (builtins.hasAttr "crowdsec-enrollment-key" config.age.secrets)
    {
      description = "Enroll CrowdSec instance in console";
      after = [ "crowdsec.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "crowdsec-console-enroll" ''
          if [ ! -f /var/lib/crowdsec/console.yaml ]; then
            /run/current-system/sw/bin/cscli console enroll \
              --name ${config.server.domain} \
              $(cat ${config.age.secrets.crowdsec-enrollment-key.path}) || true
            touch /var/lib/crowdsec/console.yaml
          fi
        '';
      };
    };

    # Ensure the crowdsec state directory and CAPI credentials file exist
    systemd.tmpfiles.rules = [
      "d /var/lib/crowdsec 0750 crowdsec crowdsec - -"
      "f /var/lib/crowdsec/online_api_credentials.yaml 0600 crowdsec crowdsec - -"
    ];

    # Ensure acquisitions are setup correctly
    assertions = lib.mapAttrsToList (name: acq: {
      assertion = acq.journalmatch != null || acq.logfiles != [];
      message = ''
        crowdsec: acquisition '${name}' has neither journalmatch nor logfiles set.
          At least one source must be specified.
      '';
    }) config.crowdsec.acquisitions;
  };
}
