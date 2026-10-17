{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.suwayomi;
  user = config.services.suwayomi-server.user;
  hasSecrets =
    config.agenix.secrets != null
    && builtins.pathExists "${config.agenix.secrets}/suwayomi-secrets.age";
  byparr = config.arrstack.enable && config.arrstack.byparr.enable;
in
{
  options.suwayomi = {
    enable = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          "local"
          "public"
        ]
      );
      default = null;
      description = "How Suwayomi is exposed. null disables it, local restricts to tailnet/LAN, public additionally exposes via the server's public domain.";
    };

    subdomain = lib.mkOption {
      type = lib.types.str;
      default = "suwayomi";
      description = "Subdomain for the Suwayomi web UI.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = config.server.defaultPorts.suwayomi;
      description = "Port for the Suwayomi web UI and API.";
    };

    downloadsPath = lib.mkOption {
      type = lib.types.path;
      default = "/data/media/manga";
      description = "Where downloaded chapters are saved as .cbz files.";
    };
  };

  config = lib.mkIf (cfg.enable != null) {

    assertions = [
      {
        assertion = cfg.enable == "public" -> hasSecrets;
        message = "suwayomi: public = true requires suwayomi-secrets.age so basic auth is enabled";
      }
    ];

    services.suwayomi-server = {
      enable = true;
      settings.server = {
        ip = "127.0.0.1";
        port = cfg.port;

        # Save chapters as .cbz so Jellyfin and other readers can open them
        downloadAsCbz = true;
        downloadsPath = cfg.downloadsPath;

        # server.conf is regenerated on every start, so settings changed in the UI revert.
        # Extension stores, extensions, the library and trackers live in the database
        # instead and are managed from the UI.

        # Stick to the WebUI shipped in the package rather than updating it from GitHub. A fresh
        # install still tries a download once before falling back to the bundled copy.
        webUIChannel = "BUNDLED";
        webUIUpdateCheckInterval = 0;

        # Check the library for new chapters and download them, even for series that are
        # not started or have unread chapters
        excludeNotStarted = false;
        excludeUnreadChapters = false;
        autoDownloadNewChapters = true;
        excludeEntryWithUnreadChapters = false;
        autoDownloadIgnoreReUploads = true;
      }
      # The start script runs envsubst over server.conf, so these placeholders are filled
      # from the secrets file and the values never reach the Nix store
      // lib.optionalAttrs hasSecrets {
        authMode = "BASIC_AUTH";
        authUsername = "$SUWAYOMI_USERNAME";
        authPassword = "$SUWAYOMI_PASSWORD";
      }
      # Let sources behind Cloudflare go through byparr
      // lib.optionalAttrs byparr {
        flareSolverrEnabled = true;
        flareSolverrUrl = "http://127.0.0.1:${toString config.arrstack.byparr.port}";
      };
    };

    # nixpkgs ships 2.1, which predates Mihon's extension stores (index.pb) and extension
    # API 1.6 that current repos such as Keiyoushi need. Drops out once nixpkgs catches up.
    services.suwayomi-server.package =
      lib.mkIf (lib.versionOlder pkgs.suwayomi-server.version "2.4.2366")
        (
          pkgs.suwayomi-server.overrideAttrs (old: {
            version = "2.4.2366";
            src = pkgs.fetchurl {
              url = "https://github.com/Suwayomi/Suwayomi-Server/releases/download/v2.4.2366/Suwayomi-Server-v2.4.2366.jar";
              hash = "sha256-r5/rIK+dfr6eMHaebG68f8erHERziNQuAoCx2l/ge/0=";
            };
          })
        );

    systemd.tmpfiles.rules = [
      "d ${cfg.downloadsPath} 0755 ${user} ${config.services.suwayomi-server.group} -"
    ];

    # The upstream module sets no sandboxing. Extensions are third-party code fetched at
    # runtime, so lock the service down to its state directory, downloads and the network.
    systemd.services.suwayomi-server.serviceConfig = {
      EnvironmentFile = lib.mkIf hasSecrets config.age.secrets.suwayomi-secrets.path;

      UMask = "0022";
      ReadWritePaths = [ cfg.downloadsPath ];

      ProtectSystem = "strict";
      ProtectHome = true;
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
      # The JVM sizes itself from /proc/meminfo and /proc/cpuinfo
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
      SystemCallFilter = [
        "@system-service"
        "~@privileged"
        "~@resources"
      ];
      SystemCallErrorNumber = "EPERM";
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_UNIX"
        "AF_NETLINK"
      ];

      # MemoryDenyWriteExecute is left off as the JVM's JIT needs writable executable memory
    };

    # CrowdSec — parse Suwayomi's systemd journal for threats
    crowdsec.acquisitions.suwayomi = {
      journalmatch = "_SYSTEMD_UNIT=suwayomi-server.service";
      type = "syslog";
    };

    # Expose Suwayomi via Caddy
    caddy.services.${cfg.subdomain} = {
      port = cfg.port;
      public = cfg.enable == "public";
    };

    # Monitor Suwayomi via uptime-kuma, checking the port as HTTP returns 401 with basic auth
    uptime-kuma.monitors.suwayomi = {
      type = "port";
      port = cfg.port;
    };

    # Create Suwayomi entry for homepage
    homepage.services.Suwayomi = {
      icon = "suwayomi.png";
      description = "Manga downloads";
      href =
        if cfg.enable == "public" then
          "https://${cfg.subdomain}.${config.server.publicDomain}"
        else
          "https://${cfg.subdomain}.${config.server.domain}";
      ping = "http://127.0.0.1:${toString cfg.port}";
      widget = {
        type = "suwayomi";
        url = "http://127.0.0.1:${toString cfg.port}";
      }
      // lib.optionalAttrs hasSecrets {
        username = "{{HOMEPAGE_VAR_SUWAYOMI_USERNAME}}";
        password = "{{HOMEPAGE_VAR_SUWAYOMI_PASSWORD}}";
      };
    };
  };
}
