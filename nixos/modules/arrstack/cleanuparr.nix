{
  config,
  lib,
  ...
}:

let
  cfg = config.arrstack.cleanuparr;
  arrOption = import ./arr-option.nix { inherit lib; };
in
{
  options.arrstack.cleanuparr =
    arrOption "Cleanuparr" config.server.defaultPorts.arrstack.cleanuparr
      "cleanuparr";

  config = lib.mkIf (config.arrstack.enable && cfg.enable) {

    systemd.tmpfiles.rules = [
      "Z /var/lib/arrstack/cleanuparr 0750 arrstack arrstack -"
    ];

    virtualisation.oci-containers.containers.cleanuparr = {
      image = "ghcr.io/cleanuparr/cleanuparr:latest";
      ports = [ "127.0.0.1:${toString cfg.port}:11011" ];
      volumes = [
        "/var/lib/arrstack/cleanuparr:/config"
        "/data/media:/data/media"
        "/data/torrents:/data/torrents"
      ];
      environment = {
        UMASK = "022";
      };
      extraOptions = [
        "--pull=newer"
        "--network=arrstack"
        "--add-host=host.containers.internal:host-gateway"
        "--userns=keep-id"
        "--group-add=keep-groups"
      ];
      podman.user = "arrstack";
    };

    systemd.services.podman-cleanuparr = {
      after = [ "arrstack-network.service" ];
      requires = [ "arrstack-network.service" ];
    };

    # Expose cleanuparr via caddy
    caddy.services.${cfg.subdomain}.port = cfg.port;

    # Monitor cleanuparr via uptime-kuma
    uptime-kuma.monitors.cleanuparr.port = cfg.port;

    # Create cleanuparr entry for homepage
    homepage.services.Cleanuparr = {
      icon = "cleanuparr.png";
      href = "https://${cfg.subdomain}.${config.server.domain}";
      description = "Torrent manager";
      ping = "http://127.0.0.1:${toString cfg.port}";
    };
  };
}
