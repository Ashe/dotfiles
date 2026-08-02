{
  config,
  lib,
  ...
}:

{
  options.tangled = {
    enable = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          "local"
          "public"
        ]
      );
      default = null;
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 7820;
      description = "Port for the tangled web UI.";
    };

    sshPort = lib.mkOption {
      type = lib.types.port;
      default = 2222;
      description = ''
        Port knot-rs's own embedded SSH server listens on. knot-rs presents
        its own SSH host key and terminates the SSH protocol itself — it
        does not use sshd's AuthorizedKeysCommand — so it cannot share
        port 22 with services.openssh on this host. See the comment above
        `networking.firewall.allowedTCPPorts` in this module for how to get
        a plain `git@host` (no port suffix) experience anyway, via a
        router-level NAT rewrite.
      '';
    };

    subdomain = lib.mkOption {
      type = lib.types.str;
      default = "knot";
      description = "Subdomain to access the knot's web UI at.";
    };

    admins = lib.mkOption {
      type = lib.types.nonEmptyListOf lib.types.str;
      default = [ "did:plc:unclaimed-local-knot" ];
      example = [ "did:plc:qfpnj4og54vl56wngdriaxug" ];
      description = ''
        atproto DIDs with knot-admin authority. The first entry is the DID
        knot-rs reports as its service owner. Required (non-placeholder)
        when tangled.enable is "public".
      '';
    };

    plcDirectory = lib.mkOption {
      type = lib.types.str;
      default = "https://plc.directory";
      description = "atproto PLC directory knot-rs resolves DIDs against.";
    };
  };

  config = lib.mkIf (config.tangled.enable != null) {

    # Allow access to secrets
    age.secrets =
      lib.mkIf
        (
          config.agenix.secrets != null && builtins.pathExists "${config.agenix.secrets}/tangled-secrets.age"
        )
        {
          tangled-secrets.mode = "0444";
        };

    services.tangled.knot-rs = {
      enable = true;

      # knot-rs's own openFirewall would open both listen_addr (HTTP) and
      # ssh_listen_addr. We want HTTP fronted by Caddy on loopback only, so
      # off here; the SSH port is opened explicitly below instead.
      openFirewall = false;

      environmentFile = lib.mkIf (
        config.agenix.secrets != null && builtins.pathExists "${config.agenix.secrets}/tangled-secrets.age"
      ) config.age.secrets.tangled-secrets.path;

      settings = {
        server =
          let
            domain =
              if config.tangled.enable == "public" then config.server.publicDomain else config.server.domain;
          in
          {
            hostname = "${config.tangled.subdomain}.${domain}";
            admins = config.tangled.admins;
            listen_addr = "127.0.0.1:${toString config.tangled.port}";
            ssh_listen_addr = "[::]:${toString config.tangled.sshPort}";
          };

        atproto.plc_directory = config.tangled.plcDirectory;
      };
    };

    # Give the web UI a real Caddy front end, same pattern as everything
    # else in this config.
    caddy.services.${config.tangled.subdomain} = {
      port = config.tangled.port;
      public = config.tangled.enable == "public";
    };

    # knot-rs's SSH port, opened on the host firewall unconditionally —
    # this only controls LAN/host-level reachability. Whether the outside
    # world can reach it at all is decided upstream of this host, at
    # your router/firewall:
    #   - homelab behind your own router/NAT: add a DNAT rule forwarding
    #     the public :22 to this host's :sshPort. Clients then just do
    #     `git@knot.example.com` with no port suffix — see the
    #     cow.computer/nixos-servers example (hosts/router2/default.nix)
    #     for the nftables rule shape:
    #       ip daddr <public-ip> meta l4proto { tcp, udp } th dport 22 \
    #         dnat ip to <this-host-lan-ip>:${toString config.tangled.sshPort}
    #   - directly internet-facing host (VPS, no NAT hop): there's nowhere
    #     to do that rewrite, so clients need `Host knot.example.com \n
    #     Port ${toString config.tangled.sshPort}` in their ~/.ssh/config,
    #     or `git@host:${toString config.tangled.sshPort}` on the command
    #     line, since sshPort can't share :22 with services.openssh here.
    networking.firewall.allowedTCPPorts = [ config.tangled.sshPort ];

    # Monitor knot HTTP availability via uptime-kuma
    uptime-kuma.monitors.tangled-knot.port = config.tangled.port;

    # CrowdSec — parse the knot's systemd journal for threats. No official
    # Tangled collection exists yet; journald acquisition + Caddy collection
    # covers HTTP-layer attacks, same rationale as Forgejo.
    crowdsec.acquisitions.tangled-knot = {
      journalmatch = "_SYSTEMD_UNIT=knot-rs.service";
      type = "syslog";
    };

    # Create Tangled entry for homepage
    homepage.services.Tangled = {
      icon = "tangled.png"; # swap for whatever icon set you're actually using — verify this exists before deploying
      description =
        if config.tangled.enable == "public" then "Git knot (atproto)" else "Git knot (private, LAN-only)";
      href =
        if config.tangled.enable == "public" then
          "https://${config.tangled.subdomain}.${config.server.publicDomain}"
        else
          "https://${config.tangled.subdomain}.${config.server.domain}";
      ping = "https://127.0.0.1:${config.tangled.port}";
    };

    assertions = [
      {
        assertion =
          config.tangled.enable != "public" || config.tangled.admins != [ "did:plc:unclaimed-local-knot" ];
        message = "tangled.enable is \"public\" but tangled.admins is still the local placeholder — a public knot needs a real atproto DID to claim it. Set tangled.admins or switch back to \"local\".";
      }
    ];
  };
}
