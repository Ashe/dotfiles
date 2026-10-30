{
  config,
  lib,
  ...
}:

let
  cfg = config.kavita;
  dataDir = config.services.kavita.dataDir;
  hasTokenKey =
    config.agenix.secrets != null
    && builtins.pathExists "${config.agenix.secrets}/kavita-token-key.age";
in
{
  options.kavita = {
    enable = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          "local"
          "public"
        ]
      );
      default = null;
      description = "How Kavita is exposed. null disables it, local restricts to tailnet/LAN, public additionally exposes via the server's public domain.";
    };

    subdomain = lib.mkOption {
      type = lib.types.str;
      default = "kavita";
      description = "Subdomain for the Kavita web UI, OPDS feeds and KOReader sync.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = config.server.defaultPorts.kavita;
      description = "Port for the Kavita web UI and API.";
    };

    libraryPaths = lib.mkOption {
      type = lib.types.listOf lib.types.path;
      default = [
        "/data/media/books"
        config.suwayomi.downloadsPath
      ];
      description = ''
        Folders Kavita can read, mounted read-only. The rest of /data is hidden from it.
        Libraries themselves are added in the web UI, pointing at these paths.
      '';
    };
  };

  config = lib.mkIf (cfg.enable != null) {

    assertions = [
      {
        assertion = hasTokenKey;
        message = "kavita: requires kavita-token-key.age, which signs Kavita's login tokens";
      }
    ];

    services.kavita = {
      enable = true;
      # Fills the default "@token_key@" placeholder in appsettings.json at startup
      credentials.token_key = config.age.secrets.kavita-token-key.path;
      settings = {
        Port = cfg.port;
        IpAddresses = "127.0.0.1";
      };
    };

    # The upstream module sets no sandboxing. Kavita only reads the library, which Shelfmark
    # and Suwayomi own, so hide the rest of /data and bind just the library folders back in
    # read-only. The "-" prefix skips any folder that does not exist yet.
    systemd.services.kavita.serviceConfig = {
      UMask = "0077";
      ReadWritePaths = [ dataDir ];

      ProtectSystem = "strict";
      ProtectHome = true;
      TemporaryFileSystem = [ "/data:ro" ];
      BindReadOnlyPaths = map (path: "-${path}") cfg.libraryPaths;
      PrivateTmp = true;
      PrivateDevices = true;
      PrivateUsers = true;
      PrivateMounts = true;
      DevicePolicy = "closed";

      ProtectHostname = true;
      ProtectClock = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectKernelLogs = true;
      ProtectControlGroups = true;
      ProtectProc = "invisible";
      # .NET sizes its GC and thread pool from /proc/meminfo, /proc/cpuinfo and cgroups
      ProcSubset = "all";

      NoNewPrivileges = true;
      CapabilityBoundingSet = "";
      AmbientCapabilities = "";
      RestrictSUIDSGID = true;
      RestrictRealtime = true;
      RestrictNamespaces = true;
      LockPersonality = true;
      RemoveIPC = true;

      SystemCallArchitectures = "native";
      # .NET is killed at startup without sched_setaffinity, so let it back in
      SystemCallFilter = [
        "@system-service"
        "~@privileged"
        "~@resources"
        "sched_setaffinity"
      ];
      SystemCallErrorNumber = "EPERM";
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_UNIX"
        "AF_NETLINK"
      ];

      # MemoryDenyWriteExecute is left off as the .NET JIT needs writable executable memory
    };

    # CrowdSec — parse Kavita's systemd journal for threats
    crowdsec.acquisitions.kavita = {
      journalmatch = "_SYSTEMD_UNIT=kavita.service";
      type = "syslog";
    };

    # Kavita answers bad passwords and bad API keys with a 401 that carries no Basic challenge,
    # so the hub's http-generic-bf misses them. Count failed logins, plus OPDS and KOReader
    # requests with an unknown key, which sits in the path. Other 401s are left out as the web
    # UI gets a burst of them whenever its session token expires.
    services.crowdsec.settings.scenarios = lib.mkIf (cfg.enable == "public") [
      {
        type = "leaky";
        name = "local/kavita-bf";
        description = "Detect Kavita login and API key brute force";
        filter = "evt.Meta.log_type == 'http_access-log' && evt.Meta.target_fqdn == '${cfg.subdomain}.${config.server.publicDomain}' && evt.Meta.http_status == '401' && (evt.Meta.http_path startsWith '/api/account/login' || evt.Meta.http_path matches '^/api/(opds|koreader)/')";
        groupby = "evt.Meta.source_ip";
        capacity = 5;
        leakspeed = "10s";
        blackhole = "1m";
        labels = {
          service = "kavita";
          behavior = "http:bruteforce";
          label = "Kavita Bruteforce";
          classification = [ "attack.T1110" ];
          confidence = 3;
          spoofable = 0;
          remediation = true;
        };
      }
    ];

    # Expose Kavita via Caddy
    caddy.services.${cfg.subdomain} = {
      port = cfg.port;
      public = cfg.enable == "public";
    };

    # Monitor Kavita via uptime-kuma
    uptime-kuma.monitors.kavita.port = cfg.port;

    # Create Kavita entry for homepage
    homepage.services.Kavita = {
      icon = "kavita.png";
      description = "Books, comics and manga";
      href =
        if cfg.enable == "public" then
          "https://${cfg.subdomain}.${config.server.publicDomain}"
        else
          "https://${cfg.subdomain}.${config.server.domain}";
      ping = "http://127.0.0.1:${toString cfg.port}";
      widget = {
        type = "kavita";
        url = "http://127.0.0.1:${toString cfg.port}";
        key = "{{HOMEPAGE_VAR_KAVITA_KEY}}";
      };
    };
  };
}
