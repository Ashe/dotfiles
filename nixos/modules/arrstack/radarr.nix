{
  config,
  lib,
  ...
}:

let
  cfg = config.arrstack.radarr;
  arrOption = import ./arr-option.nix { inherit lib; };
in
{
  options.arrstack.radarr = arrOption "Radarr" config.server.defaultPorts.arrstack.radarr "radarr";

  config = lib.mkIf (config.arrstack.enable && cfg.enable) {

    systemd.tmpfiles.rules = [
      "d /var/lib/arrstack/radarr 0750 arrstack arrstack -"
    ];

    services.radarr = {
      enable = true;
      user = "arrstack";
      group = "arrstack";
      dataDir = "/var/lib/arrstack/radarr";
      settings.server.port = cfg.port;
    };

    # Expose radarr via caddy
    caddy.services.${cfg.subdomain}.port = cfg.port;

    # Monitor radarr via uptime-kuma
    uptime-kuma.monitors.radarr.port = cfg.port;

    # Create radarr entry for homepage
    homepage.services.Radarr = {
      icon = "radarr.png";
      href = "https://${cfg.subdomain}.${config.server.domain}";
      description = "Movie management";
      ping = "http://127.0.0.1:${toString cfg.port}";
      widget = {
        type = "radarr";
        url = "http://127.0.0.1:${toString cfg.port}";
        key = "{{HOMEPAGE_VAR_RADARR_KEY}}";
      };
    };
  };
}
