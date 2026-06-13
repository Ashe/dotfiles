{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.wireguard = {
    enable = lib.mkEnableOption "WireGuard VPN network namespace";

    dns = lib.mkOption {
      type = lib.types.str;
      default = "10.64.0.1";
      description = "DNS server to use inside the VPN namespace.";
    };

    namespaceIP = lib.mkOption {
      type = lib.types.str;
      default = "192.168.50.2";
      description = "IP that services inside the VPN namespace bind to, reachable from the host.";
    };

    allowedIPs = lib.mkOption {
      type = lib.types.str;
      default = "0.0.0.0/0";
      description = "Allowed IPs for the WireGuard peer (traffic to route through VPN).";
    };

    services = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        List of systemd service names to confine to the VPN namespace.
        Each service will be given NetworkNamespacePath and made to
        require vpn-namespace.service and vpn-wireguard.service.
      '';
    };
  };

  config = lib.mkIf config.wireguard.enable {

    systemd.services = lib.mkMerge [

      # Step 1: create the network namespace
      {
        vpn-namespace = {
          description = "Create VPN network namespace";
          before = [ "vpn-wireguard.service" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStart = "${pkgs.iproute2}/bin/ip netns add vpnns";
            ExecStop = "${pkgs.iproute2}/bin/ip netns del vpnns || true";
          };
        };
      }

      # Step 2: bring up WireGuard inside the namespace using wg-quick
      {
        vpn-wireguard = {
          description = "WireGuard VPN inside vpnns namespace";
          after = [
            "vpn-namespace.service"
            "network-online.target"
          ];
          requires = [ "vpn-namespace.service" ];
          wants = [ "network-online.target" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStart =
              let
                secretPath = config.age.secrets.wireguard-conf.path;
                grep = "${pkgs.gnugrep}/bin/grep";
                awk = "${pkgs.gawk}/bin/awk";
                ip = "${pkgs.iproute2}/bin/ip";
                wg = "${pkgs.wireguard-tools}/bin/wg";
                mktemp = "${pkgs.coreutils}/bin/mktemp";
                rm = "${pkgs.coreutils}/bin/rm";
                mkdir = "${pkgs.coreutils}/bin/mkdir";
                tr = "${pkgs.coreutils}/bin/tr";
                parseConf = field: "${grep} -i '^${field}' ${secretPath} | ${awk} '{print $3}'";
              in
              pkgs.writeShellScript "vpn-wireguard-up" ''
                    set -e

                    # Cleanup — must succeed even if interfaces don't exist yet
                    ${ip} netns exec vpnns ${ip} link del wg0 2>/dev/null || true
                    ${ip} link del veth-vpn 2>/dev/null || true

                    ${ip} netns exec vpnns ${ip} link add wg0 type wireguard

                    PRIVATE_KEY=$(${parseConf "PrivateKey"})
                    ADDRESS=$(${parseConf "Address"})
                    PEER_PUBLIC_KEY=$(${parseConf "PublicKey"})
                    ENDPOINT=$(${parseConf "Endpoint"})
                    PRESHARED_KEY=$(${parseConf "PresharedKey"})

                    TMPCONF=$(${mktemp})

                    # Build peer section conditionally
                    PEER_SECTION="[Peer]
                PublicKey = $PEER_PUBLIC_KEY
                AllowedIPs = ${config.wireguard.allowedIPs}
                Endpoint = $ENDPOINT"

                    if [ -n "$PRESHARED_KEY" ]; then
                      PEER_SECTION="$PEER_SECTION
                PresharedKey = $PRESHARED_KEY"
                    fi

                    printf '[Interface]\nPrivateKey = %s\n\n%s\n' \
                      "$PRIVATE_KEY" "$PEER_SECTION" > "$TMPCONF"

                    ${ip} netns exec vpnns ${wg} setconf wg0 "$TMPCONF"
                    ${rm} -f "$TMPCONF"

                    echo "$ADDRESS" | ${tr} ',' '\n' | while read -r addr; do
                      addr=$(echo "$addr" | ${tr} -d ' ')
                      ${ip} netns exec vpnns ${ip} addr add "$addr" dev wg0
                    done

                    ${ip} netns exec vpnns ${ip} link set wg0 up
                    ${ip} netns exec vpnns ${ip} route add default dev wg0

                    # Veth pair for host<->namespace communication
                    ${ip} link add veth-vpn type veth peer name veth-ns
                    ${ip} link set veth-ns netns vpnns
                    ${ip} addr add 192.168.50.1/30 dev veth-vpn
                    ${ip} netns exec vpnns ${ip} addr add ${config.wireguard.namespaceIP}/30 dev veth-ns
                    ${ip} link set veth-vpn up
                    ${ip} netns exec vpnns ${ip} link set veth-ns up

                    # Route WireGuard endpoint via host so handshake can complete
                    ENDPOINT_IP=$(echo "$ENDPOINT" | ${pkgs.coreutils}/bin/cut -d: -f1)
                    ${ip} netns exec vpnns ${ip} route add "$ENDPOINT_IP/32" via 192.168.50.1

                    echo 1 > /proc/sys/net/ipv4/ip_forward
                    ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 192.168.50.0/30 -j MASQUERADE

                    ${mkdir} -p /etc/netns/vpnns
                    echo "nameserver ${config.wireguard.dns}" > /etc/netns/vpnns/resolv.conf
              '';

            ExecStop = pkgs.writeShellScript "vpn-wireguard-down" ''
              ${pkgs.iproute2}/bin/ip netns exec vpnns \
                ${pkgs.iproute2}/bin/ip link del wg0 || true
              ${pkgs.iproute2}/bin/ip link del veth-vpn || true
              ${pkgs.coreutils}/bin/rm -f /etc/netns/vpnns/resolv.conf
              ${pkgs.coreutils}/bin/rmdir /etc/netns/vpnns || true
              ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 192.168.50.0/30 -j MASQUERADE
            '';
          };
        };
      }

      # Step 3: confine each registered service to the namespace
      (lib.mkMerge (
        map (svc: {
          ${svc} = {
            after = [ "vpn-wireguard.service" ];
            requires = [ "vpn-wireguard.service" ];
            serviceConfig = {
              NetworkNamespacePath = "/run/netns/vpnns";
            };
          };
        }) config.wireguard.services
      ))

      # Step 4: WireGuard health check HTTP server inside the namespace
      {
        vpn-health = {
          description = "WireGuard health check endpoint inside vpnns";
          after = [ "vpn-wireguard.service" ];
          requires = [ "vpn-wireguard.service" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            NetworkNamespacePath = "/run/netns/vpnns";
            Type = "simple";
            Restart = "always";
            RestartSec = "5s";
            # Never stop retrying to restart health server
            StartLimitIntervalSec = 0;
            ExecStart = pkgs.writeShellScript "vpn-health-serve" ''
                ${pkgs.python3}/bin/python3 -c "
              import http.server, subprocess, time

              class Handler(http.server.BaseHTTPRequestHandler):
                def do_GET(self):
                  try:
                    out = subprocess.check_output(
                      ['${pkgs.wireguard-tools}/bin/wg', 'show', 'wg0', 'latest-handshakes'],
                      text=True, timeout=5)
                    ts = int(out.strip().split()[1])
                    healthy = (time.time() - ts) < 180
                  except Exception:
                    healthy = False
                  code = 200 if healthy else 503
                  body = b'OK' if healthy else b'DOWN'
                  self.send_response(code)
                  self.send_header('Content-Length', len(body))
                  self.end_headers()
                  self.wfile.write(body)
                def log_message(self, *args):
                  pass

              http.server.HTTPServer(('${config.wireguard.namespaceIP}', 9999), Handler).serve_forever()
              "
            '';
          };
        };
      }

    ];

    # Ensure config secret is accessible
    age.secrets.wireguard-conf.mode = "0400";

    # Monitor wireguard with uptime-kuma
    uptime-kuma.monitors.wireguard = {
      host = config.wireguard.namespaceIP;
      port = 9999;
    };

    # Create wireguard entry for homepage
    homepage.services.Wireguard = {
      icon = "wireguard.png";
      description = "VPN tunnel";
      siteMonitor = "http://${config.wireguard.namespaceIP}:9999";
    };

    # Assert that a wireguard config file is provided
    assertions = [
      {
        assertion =
          config.agenix.secrets != null && builtins.pathExists "${config.agenix.secrets}/wireguard-conf.age";
        message = "wireguard: wireguard-conf.age secret is required but was not found in ${config.agenix.secrets}";
      }
    ];
  };
}
