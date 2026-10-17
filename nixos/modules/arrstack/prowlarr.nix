{
  config,
  lib,
  ...
}:

let
  cfg = config.arrstack.prowlarr;
  arrOption = import ./arr-option.nix { inherit lib; };
in
{
  options.arrstack.prowlarr =
    arrOption "Prowlarr" config.server.defaultPorts.arrstack.prowlarr
      "prowlarr";

  config = lib.mkIf (config.arrstack.enable && cfg.enable) {

    services.prowlarr = {
      enable = true;
      settings.server.port = cfg.port;
    };

    # Expose prowlarr via caddy
    caddy.services.${cfg.subdomain}.port = cfg.port;

    # Monitor prowlarr via uptime-kuma
    uptime-kuma.monitors.prowlarr.port = cfg.port;

    # Create prowlarr entry for homepage
    homepage.services.Prowlarr = {
      icon = "prowlarr.png";
      href = "https://${cfg.subdomain}.${config.server.domain}";
      description = "Indexer management";
      ping = "http://127.0.0.1:${toString cfg.port}";
      widget = {
        type = "prowlarr";
        url = "http://127.0.0.1:${toString cfg.port}";
        key = "{{HOMEPAGE_VAR_PROWLARR_KEY}}";
      };
    };
  };
}
