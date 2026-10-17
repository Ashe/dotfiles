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

  config = lib.mkIf (config.arrstack.enable && cfg.enable) (
    lib.mkMerge [
      {
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
          description = "Cloudflare solver (non-VPN)";
          ping = "http://127.0.0.1:${toString cfg.port}";
        };
      }

      # Cloudflare clearance is tied to the IP that solved it, so services inside the VPN
      # need a byparr that also goes out through the VPN. It shares the namespace's network
      # and listens on byparr's own port 8191 there.
      (lib.mkIf config.wireguard.enable {
        virtualisation.oci-containers.containers.byparr-vpn = {
          image = "ghcr.io/thephaseless/byparr:latest";
          extraOptions = [
            "--pull=newer"
            "--network=host"
          ];
          podman.user = "arrstack";
        };

        wireguard.services = [ "podman-byparr-vpn" ];

        # Monitor byparr-vpn via uptime-kuma
        uptime-kuma.monitors.byparr-vpn = {
          host = config.wireguard.namespaceIP;
          port = 8191;
        };

        # Create byparr-vpn entry for homepage
        homepage.services."Byparr VPN" = {
          icon = "byparr.png";
          description = "Cloudflare solver (VPN)";
          ping = "http://${config.wireguard.namespaceIP}:8191";
        };
      })
    ]
  );
}
