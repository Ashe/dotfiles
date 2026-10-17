{
  config,
  lib,
  ...
}:

let
  hasSecrets =
    config.agenix.secrets != null
    && builtins.pathExists "${config.agenix.secrets}/configarr-secrets.age";
in
{
  options.arrstack.configarr = lib.mkEnableOption "configarr (TRaSH Guide sync)" // {
    default = true;
  };

  config = lib.mkIf (config.arrstack.enable && config.arrstack.configarr) (
    lib.mkMerge [
      {
        systemd.tmpfiles.rules = [
          "d /var/lib/arrstack/configarr 0755 arrstack arrstack -"
          "d /var/lib/arrstack/configarr/repos 0755 arrstack arrstack -"
        ];
      }

      (lib.mkIf hasSecrets {
        age.secrets.configarr-secrets.mode = "0444";

        systemd.services.configarr = {
          description = "configarr: sync TRaSH Guide configurations to Sonarr/Radarr";
          after = [
            "network-online.target"
          ]
          ++ lib.optionals config.arrstack.sonarr.enable [ "sonarr.service" ]
          ++ lib.optionals config.arrstack.radarr.enable [ "radarr.service" ];
          wants = [ "network-online.target" ];
          serviceConfig = {
            Type = "oneshot";
            User = "arrstack";
            StandardOutput = "journal";
            StandardError = "journal";
            ExecStart =
              "${config.virtualisation.podman.package}/bin/podman run --rm"
              + " --name=configarr --network=host --pull=newer --log-driver=journald"
              + " -e CONFIG_LOCATION=/app/config.yml"
              + " -e SECRETS_LOCATION=/app/secrets.yml"
              + " -v ${./configarr.yml}:/app/config.yml:ro"
              + " -v ${config.age.secrets.configarr-secrets.path}:/app/secrets.yml:ro"
              + " -v /var/lib/arrstack/configarr/repos:/app/repos"
              + " ghcr.io/raydak-labs/configarr:latest";
          };
        };

        systemd.timers.configarr = {
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnBootSec = "5min";
            OnUnitActiveSec = "6h";
            Unit = "configarr.service";
          };
        };
      })
    ]
  );
}
