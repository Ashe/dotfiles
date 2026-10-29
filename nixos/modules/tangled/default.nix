{
  config,
  lib,
  ...
}:

let
  domain =
    if config.tangled.enable == "public" then config.server.publicDomain else config.server.domain;
  hostname = "${config.tangled.subdomain}.${domain}";
  hasSecrets =
    config.agenix.secrets != null && builtins.pathExists "${config.agenix.secrets}/tangled-secrets.age";
in
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
      default = config.server.defaultPorts.tangled.web;
      description = "Port for the knot's HTTP API.";
    };

    sshPort = lib.mkOption {
      type = lib.types.port;
      default = config.server.defaultPorts.tangled.ssh;
      description = "Port for the knot's built-in SSH server. Must not clash with sshd.";
    };

    subdomain = lib.mkOption {
      type = lib.types.str;
      default = "knot";
      description = "Subdomain to access the knot at. Doubles as its identity, so don't change it once registered.";
    };

    admins = lib.mkOption {
      type = lib.types.nonEmptyListOf lib.types.str;
      default = [ "did:plc:unclaimed-local-knot" ];
      example = [ "did:plc:qfpnj4og54vl56wngdriaxug" ];
      description = "atproto DIDs with admin rights. The first one owns the knot.";
    };

    plcDirectory = lib.mkOption {
      type = lib.types.str;
      default = "https://plc.directory";
      description = "atproto PLC directory to resolve DIDs against.";
    };
  };

  config = lib.mkIf (config.tangled.enable != null) {

    # Must contain KNOT_MASTER_KEY and KNOT_CONTACT_EMAIL
    age.secrets = lib.mkIf hasSecrets { tangled-secrets = { }; };

    services.tangled.knot-rs = {
      enable = true;

      # HTTP stays behind Caddy, SSH port is opened below
      openFirewall = false;

      environmentFile = lib.mkIf hasSecrets config.age.secrets.tangled-secrets.path;

      settings = {
        server = {
          inherit hostname;
          admins = config.tangled.admins;
          listen_addr = "127.0.0.1:${toString config.tangled.port}";
          ssh_listen_addr = "[::]:${toString config.tangled.sshPort}";
        };

        # Required by the module, overridden by KNOT_CONTACT_EMAIL from the secret
        contact.email = "unset@example.invalid";
        git.object_format = "sha256";
        atproto.plc_directory = config.tangled.plcDirectory;

        # Rate limit per client rather than per Caddy
        xrpc = {
          trusted_proxy_header = "x-forwarded-for";
          trusted_proxies = [
            "127.0.0.1"
            "::1"
          ];
        };
      };
    };

    # Expose the knot via Caddy
    caddy.services.${config.tangled.subdomain} = {
      port = config.tangled.port;
      public = config.tangled.enable == "public";
    };

    # Allow knot ssh port through firewall
    networking.firewall.allowedTCPPorts = [ config.tangled.sshPort ];

    # Monitor knot HTTP availability via uptime-kuma
    uptime-kuma.monitors.tangled-knot = {
      port = config.tangled.port;
      path = "/xrpc/_health";
    };

    # CrowdSec — parse the knot's systemd journal for threats.
    # Named after the Caddy service, as public Caddy services require.
    crowdsec.acquisitions.${config.tangled.subdomain} = {
      journalmatch = "_SYSTEMD_UNIT=knot-rs.service";
      type = "syslog";
    };

    # Create Tangled entry for homepage
    homepage.services.Tangled = {
      icon = "si-tangled";
      description = "Git knot";
      href = "https://tangled.org/settings/knots";
      ping = "http://127.0.0.1:${toString config.tangled.port}/xrpc/_health";

      # Count hosted repos, each one is its own atproto account
      widget = {
        type = "customapi";
        url = "http://127.0.0.1:${toString config.tangled.port}/xrpc/com.atproto.sync.listRepos?limit=1000";
        mappings = [
          {
            field = "repos";
            label = "Repos";
            format = "size";
          }
        ];
      };
    };

    assertions = [
      {
        assertion =
          config.tangled.enable != "public" || config.tangled.admins != [ "did:plc:unclaimed-local-knot" ];
        message = "tangled.enable is \"public\" but tangled.admins is still the placeholder. Set a real atproto DID.";
      }
      {
        assertion = hasSecrets;
        message = "tangled.enable is set but tangled-secrets.age doesn't exist. It needs KNOT_MASTER_KEY=$(openssl rand -base64 32) and KNOT_CONTACT_EMAIL.";
      }
      {
        assertion =
          !config.ssh.enable
          || !(lib.elem config.tangled.sshPort (
            [ config.ssh.local.port ] ++ lib.optional config.ssh.public.enable config.ssh.public.port
          ));
        message = "tangled.sshPort (${toString config.tangled.sshPort}) clashes with ssh.local.port or ssh.public.port.";
      }
    ];
  };
}
