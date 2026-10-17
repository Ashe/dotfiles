{
  config,
  lib,
  ...
}:

let
  cfg = config.arrstack.byparr;
  arrOption = import ./arr-option.nix { inherit lib; };
in
{
  options.arrstack.byparr = arrOption "Byparr" config.server.defaultPorts.arrstack.byparr null;

  config = lib.mkIf (config.arrstack.enable && cfg.enable) {

    systemd.tmpfiles.rules = [
      "d /var/lib/arrstack/byparr 0777 arrstack arrstack -"
    ];

    virtualisation.oci-containers.containers.byparr = {
      image = "ghcr.io/thephaseless/byparr:latest";
      ports = [ "127.0.0.1:${toString cfg.port}:8191" ];
      extraOptions = [
        "--pull=newer"
        "--network=arrstack"
      ];
      podman.user = "arrstack";
    };

    systemd.services.podman-byparr = {
      after = [ "arrstack-network.service" ];
      requires = [ "arrstack-network.service" ];
    };

    # Monitor byparr via uptime-kuma
    uptime-kuma.monitors.byparr.port = cfg.port;

    # Create byparr entry for homepage
    homepage.services.Byparr = {
      icon = "byparr.png";
      description = "Indexer proxy";
      ping = "http://127.0.0.1:${toString cfg.port}";
    };
  };
}
