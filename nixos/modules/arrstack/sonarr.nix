{
  config,
  lib,
  ...
}:

let
  cfg = config.arrstack.sonarr;
  arrOption = import ./arr-option.nix { inherit lib; };
in
{
  options.arrstack.sonarr = arrOption "Sonarr" config.server.defaultPorts.arrstack.sonarr "sonarr";

  config = lib.mkIf (config.arrstack.enable && cfg.enable) {

    systemd.tmpfiles.rules = [
      "d /var/lib/arrstack/sonarr 0750 arrstack arrstack -"
    ];

    services.sonarr = {
      enable = true;
      user = "arrstack";
      group = "arrstack";
      dataDir = "/var/lib/arrstack/sonarr";
      settings.server.port = cfg.port;
    };

    # Expose sonarr via caddy
    caddy.services.${cfg.subdomain}.port = cfg.port;

    # Monitor sonarr via uptime-kuma
    uptime-kuma.monitors.sonarr.port = cfg.port;

    # Create sonarr entry for homepage
    homepage.services.Sonarr = {
      icon = "sonarr.png";
      href = "https://${cfg.subdomain}.${config.server.domain}";
      description = "TV show management";
      ping = "http://127.0.0.1:${toString cfg.port}";
      widget = {
        type = "sonarr";
        url = "http://127.0.0.1:${toString cfg.port}";
        key = "{{HOMEPAGE_VAR_SONARR_KEY}}";
        enableQueue = true;
      };
    };
  };
}
