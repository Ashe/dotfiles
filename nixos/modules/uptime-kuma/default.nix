{
  config,
  lib,
  pkgs,
  ...
}:

let
  tomlFormat = pkgs.formats.toml { };

  # Generate a directory of .toml files, one per declared monitor
  monitorsDir = pkgs.linkFarm "autokuma-monitors" (
    lib.mapAttrsToList (
      id: monitor:
      let
        fields = {
          inherit (monitor) type interval;
          name = monitor.name;
        }
        // lib.optionalAttrs (monitor.type == "http") {
          url = "http://${monitor.hostname}:${toString monitor.port}${monitor.path}";
        }
        // lib.optionalAttrs (monitor.type == "port") {
          inherit (monitor) hostname port;
        };
      in
      {
        name = "${id}.toml";
        path = tomlFormat.generate "${id}.toml" fields;
      }
    ) config.uptime-kuma.monitors
  );
in

{
  options.uptime-kuma = {
    enable = lib.mkEnableOption "uptime-kuma";

    monitors = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule (
          { name, ... }:
          {
            options = {
              name = lib.mkOption {
                type = lib.types.str;
                default = name;
                description = "Display name shown in the uptime-kuma dashboard";
              };
              type = lib.mkOption {
                type = lib.types.enum [
                  "http"
                  "port"
                ];
                default = "http";
              };
              port = lib.mkOption {
                type = lib.types.port;
                description = "Port to monitor on the local host";
              };
              hostname = lib.mkOption {
                type = lib.types.str;
                default = "127.0.0.1";
              };
              path = lib.mkOption {
                type = lib.types.str;
                default = "";
                description = "URL path appended to the HTTP monitor URL (e.g. \"/myservice\").";
              };
              interval = lib.mkOption {
                type = lib.types.int;
                default = 60;
              };
            };
          }
        )
      );
      default = { };
      description = "Monitors declaratively managed via AutoKuma. Other modules append to this.";
    };
  };

  config = lib.mkIf config.uptime-kuma.enable {

    # Enable uptime-kuma, a self-hosted uptime monitor and status page
    services.uptime-kuma = {
      enable = true;
      settings = {
        HOST = "127.0.0.1";
        PORT = "3001";
      };
    };

    # AutoKuma syncs declarative monitors into uptime-kuma via its socket API.
    # Enabled only once the credentials secret exists — create it first, then redeploy.
    age.secrets.uptime-kuma-credentials.mode = lib.mkIf (
      config.agenix.secrets != null
      && builtins.pathExists "${config.agenix.secrets}/uptime-kuma-credentials.age"
    ) "0444";

    systemd.services.autokuma =
      lib.mkIf
        (
          config.agenix.secrets != null
          && builtins.pathExists "${config.agenix.secrets}/uptime-kuma-credentials.age"
        )
        {
          description = "AutoKuma — declarative Uptime Kuma monitor sync";
          after = [ "uptime-kuma.service" ];
          requires = [ "uptime-kuma.service" ];
          wantedBy = [ "multi-user.target" ];
          environment = {
            AUTOKUMA__KUMA__URL = "http://127.0.0.1:3001";
            AUTOKUMA__STATIC_MONITORS = "${monitorsDir}";
            AUTOKUMA__DOCKER__ENABLED = "false";
            AUTOKUMA__FILES__FOLLOW_SYMLINKS = "true";
            AUTOKUMA__DATA_PATH = "/var/lib/autokuma";
            RUST_LOG = "autokuma=info";
          };
          serviceConfig = {
            Type = "simple";
            ExecStart = "${pkgs.autokuma}/bin/autokuma";
            EnvironmentFile = config.age.secrets.uptime-kuma-credentials.path;
            DynamicUser = true;
            StateDirectory = "autokuma";
            Restart = "on-failure";
            RestartSec = "10s";
            LogRateLimitIntervalSec = 0;
          };
        };

    # Expose uptime-kuma via caddy
    caddy.services.uptime-kuma.port = 3001;

    # Monitor uptime-kuma itself
    uptime-kuma.monitors.uptime-kuma = {
      port = 3001;
    };
  };
}
