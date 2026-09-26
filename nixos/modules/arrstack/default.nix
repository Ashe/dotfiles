{
  config,
  lib,
  ...
}:

{
  options.arrstack =
    let
      arrOption =
        description: defaultPort: defaultSubdomain:
        lib.mkOption {
          type = lib.types.coercedTo lib.types.bool (enable: { inherit enable; }) (
            lib.types.submodule {
              options = {
                enable = lib.mkEnableOption description // {
                  default = true;
                };
                port = lib.mkOption {
                  type = lib.types.port;
                  default = defaultPort;
                  description = "Port for ${description}.";
                };
              }
              // lib.optionalAttrs (defaultSubdomain != null) {
                subdomain = lib.mkOption {
                  type = lib.types.str;
                  default = defaultSubdomain;
                  description = "Subdomain for ${description}.";
                };
              };
            }
          );
          default = { };
          description = "Configuration for ${description}.";
        };
    in
    {
      enable = lib.mkEnableOption "arrstack";

      sonarr = arrOption "Sonarr" config.server.defaultPorts.arrstack.sonarr "sonarr";
      radarr = arrOption "Radarr" config.server.defaultPorts.arrstack.radarr "radarr";
      shelfmark = arrOption "Shelfmark" config.server.defaultPorts.arrstack.shelfmark "shelfmark";
      prowlarr = arrOption "Prowlarr" config.server.defaultPorts.arrstack.prowlarr "prowlarr";
      cleanuparr = arrOption "Cleanuparr" config.server.defaultPorts.arrstack.cleanuparr "cleanuparr";
      byparr = arrOption "Byparr" config.server.defaultPorts.arrstack.byparr null;
      configarr = lib.mkEnableOption "configarr (TRaSH Guide sync)" // {
        default = true;
      };
    };

  config = lib.mkIf config.arrstack.enable {

    users.users.arrstack = {
      isSystemUser = true;
      uid = 990;
      group = "arrstack";
      home = "/var/lib/arrstack";
      createHome = true;
      extraGroups = [ "qbittorrent" ];
      linger = true;
      subUidRanges = [
        {
          startUid = 100000;
          count = 65536;
        }
      ];
      subGidRanges = [
        {
          startGid = 100000;
          count = 65536;
        }
      ];
    };

    users.groups.arrstack = {
      gid = 990;
    };

    systemd.tmpfiles.rules = [
      "d /data/media 0755 arrstack arrstack -"
      "d /data/media/movies 0755 arrstack arrstack -"
      "d /data/media/shows 0755 arrstack arrstack -"
      "d /data/media/anime 0755 arrstack arrstack -"
      "d /data/media/music 0755 arrstack arrstack -"
    ]
    ++ lib.optionals config.arrstack.shelfmark.enable [
      "d /data/media/books 0755 arrstack arrstack -"
      "d /data/media/audiobooks 0755 arrstack arrstack -"
      "d /var/lib/arrstack/shelfmark 0750 arrstack arrstack -"
    ]
    ++ lib.optionals config.arrstack.sonarr.enable [
      "d /var/lib/arrstack/sonarr 0750 arrstack arrstack -"
    ]
    ++ lib.optionals config.arrstack.radarr.enable [
      "d /var/lib/arrstack/radarr 0750 arrstack arrstack -"
    ]
    ++ lib.optionals config.arrstack.cleanuparr.enable [
      "Z /var/lib/arrstack/cleanuparr 0750 arrstack arrstack -"
    ]
    ++ lib.optionals config.arrstack.byparr.enable [
      "d /var/lib/arrstack/byparr 0777 arrstack arrstack -"
    ]
    ++ lib.optionals config.arrstack.configarr [
      "d /var/lib/arrstack/configarr 0755 arrstack arrstack -"
      "d /var/lib/arrstack/configarr/repos 0755 arrstack arrstack -"
    ];

    age.secrets =
      lib.mkIf
        (
          config.arrstack.configarr
          && config.agenix.secrets != null
          && builtins.pathExists "${config.agenix.secrets}/configarr-secrets.age"
        )
        {
          configarr-secrets.mode = "0444";
        };

    services.sonarr = lib.mkIf config.arrstack.sonarr.enable {
      enable = true;
      user = "arrstack";
      group = "arrstack";
      dataDir = "/var/lib/arrstack/sonarr";
      settings.server.port = config.arrstack.sonarr.port;
    };

    services.radarr = lib.mkIf config.arrstack.radarr.enable {
      enable = true;
      user = "arrstack";
      group = "arrstack";
      dataDir = "/var/lib/arrstack/radarr";
      settings.server.port = config.arrstack.radarr.port;
    };

    services.shelfmark = lib.mkIf config.arrstack.shelfmark.enable {
      enable = true;
      environment = {
        FLASK_PORT = config.arrstack.shelfmark.port;
        CONFIG_DIR = "/var/lib/arrstack/shelfmark";
        # arrstack's home is read-only in the sandbox, so gunicorn needs a writable HOME
        HOME = "/var/lib/arrstack/shelfmark";

        # Lay files out the way Jellyfin expects: one folder per book, grouped by author
        INGEST_DIR = "/data/media/books";
        FILE_ORGANIZATION = "organize";
        TEMPLATE_ORGANIZE = "{Author}/{Title} ({Year})/{Title}";
        DESTINATION_AUDIOBOOK = "/data/media/audiobooks";
        FILE_ORGANIZATION_AUDIOBOOK = "organize";

        # ReadWritePaths are separate bind mounts, so hardlinks out of /data/torrents fail with EXDEV
        HARDLINK_TORRENTS = "false";
        HARDLINK_TORRENTS_AUDIOBOOK = "false";
      }
      # The nixpkgs package always uses an external bypasser, so point it at byparr
      // lib.optionalAttrs config.arrstack.byparr.enable {
        EXT_BYPASSER_URL = "http://127.0.0.1:${toString config.arrstack.byparr.port}";
      }
      // lib.optionalAttrs config.arrstack.prowlarr.enable {
        PROWLARR_URL = "http://127.0.0.1:${toString config.arrstack.prowlarr.port}";
      }
      // lib.optionalAttrs config.qbittorrent.enable {
        QBITTORRENT_URL = "http://${config.wireguard.namespaceIP}:${toString config.qbittorrent.port}";
        QBITTORRENT_CATEGORY = "books";
      };
    };

    services.prowlarr = lib.mkIf config.arrstack.prowlarr.enable {
      enable = true;
      settings.server.port = config.arrstack.prowlarr.port;
    };

    systemd.services = lib.mkMerge [

      {
        arrstack-network = {
          description = "Create arrstack Podman network";
          after = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            User = "arrstack";
            ExecStart = "/bin/sh -c '${config.virtualisation.podman.package}/bin/podman network create arrstack || true'";
          };
        };
      }

      (lib.mkIf config.arrstack.shelfmark.enable {
        shelfmark.serviceConfig = {
          DynamicUser = lib.mkForce false;
          User = "arrstack";
          Group = "arrstack";
          StateDirectory = lib.mkForce "";
          UMask = lib.mkForce "0022";
          ReadWritePaths = [
            "/var/lib/arrstack/shelfmark"
            "/data/media/books"
            "/data/media/audiobooks"
          ];

          # API keys and passwords, e.g. PROWLARR_API_KEY, QBITTORRENT_PASSWORD, HARDCOVER_API_KEY
          EnvironmentFile = lib.mkIf (builtins.hasAttr "shelfmark-secrets" config.age.secrets) config.age.secrets.shelfmark-secrets.path;
        };
      })

      (lib.mkIf config.arrstack.cleanuparr.enable {
        podman-cleanuparr.after = [ "arrstack-network.service" ];
        podman-cleanuparr.requires = [ "arrstack-network.service" ];
      })

      (lib.mkIf config.arrstack.byparr.enable {
        podman-byparr.after = [ "arrstack-network.service" ];
        podman-byparr.requires = [ "arrstack-network.service" ];
      })

      (lib.mkIf
        (
          config.arrstack.configarr
          && config.agenix.secrets != null
          && builtins.pathExists "${config.agenix.secrets}/configarr-secrets.age"
        )
        {
          configarr = {
            description = "configarr: sync TRaSH Guide configurations to Sonarr/Radarr";
            after = [
              "network-online.target"
            ]
            ++ lib.optionals config.arrstack.sonarr.enable [ "sonarr.service" ]
            ++ lib.optionals config.arrstack.radarr.enable [ "radarr.service" ];
            wants = [ "network-online.target" ];
            serviceConfig = {
              Type = "oneshot";
              User = "arrstack";
              StandardOutput = "journal";
              StandardError = "journal";
              ExecStart =
                "${config.virtualisation.podman.package}/bin/podman run --rm"
                + " --name=configarr --network=host --pull=newer --log-driver=journald"
                + " -e CONFIG_LOCATION=/app/config.yml"
                + " -e SECRETS_LOCATION=/app/secrets.yml"
                + " -v ${./configarr.yml}:/app/config.yml:ro"
                + " -v ${config.age.secrets.configarr-secrets.path}:/app/secrets.yml:ro"
                + " -v /var/lib/arrstack/configarr/repos:/app/repos"
                + " ghcr.io/raydak-labs/configarr:latest";
            };
          };
        }
      )
    ];

    systemd.timers =
      lib.mkIf
        (
          config.arrstack.configarr
          && config.agenix.secrets != null
          && builtins.pathExists "${config.agenix.secrets}/configarr-secrets.age"
        )
        {
          configarr = {
            wantedBy = [ "timers.target" ];
            timerConfig = {
              OnBootSec = "5min";
              OnUnitActiveSec = "6h";
              Unit = "configarr.service";
            };
          };
        };

    virtualisation.oci-containers.containers = {

      cleanuparr = lib.mkIf config.arrstack.cleanuparr.enable {
        image = "ghcr.io/cleanuparr/cleanuparr:latest";
        ports = [ "127.0.0.1:${toString config.arrstack.cleanuparr.port}:11011" ];
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

      byparr = lib.mkIf config.arrstack.byparr.enable {
        image = "ghcr.io/thephaseless/byparr:latest";
        ports = [ "127.0.0.1:${toString config.arrstack.byparr.port}:8191" ];
        extraOptions = [
          "--pull=newer"
          "--network=arrstack"
        ];
        podman.user = "arrstack";
      };
    };

    # Expose services via caddy
    caddy.services = lib.mkMerge [
      (lib.mkIf config.arrstack.prowlarr.enable {
        ${config.arrstack.prowlarr.subdomain}.port = config.arrstack.prowlarr.port;
      })
      (lib.mkIf config.arrstack.sonarr.enable {
        ${config.arrstack.sonarr.subdomain}.port = config.arrstack.sonarr.port;
      })
      (lib.mkIf config.arrstack.radarr.enable {
        ${config.arrstack.radarr.subdomain}.port = config.arrstack.radarr.port;
      })
      (lib.mkIf config.arrstack.shelfmark.enable {
        ${config.arrstack.shelfmark.subdomain}.port = config.arrstack.shelfmark.port;
      })
      (lib.mkIf config.arrstack.cleanuparr.enable {
        ${config.arrstack.cleanuparr.subdomain}.port = config.arrstack.cleanuparr.port;
      })
    ];

    # Monitor services via uptime-kuma
    uptime-kuma.monitors = lib.mkMerge [
      (lib.mkIf config.arrstack.prowlarr.enable {
        prowlarr.port = config.arrstack.prowlarr.port;
      })
      (lib.mkIf config.arrstack.sonarr.enable { sonarr.port = config.arrstack.sonarr.port; })
      (lib.mkIf config.arrstack.radarr.enable { radarr.port = config.arrstack.radarr.port; })
      (lib.mkIf config.arrstack.shelfmark.enable { shelfmark.port = config.arrstack.shelfmark.port; })
      (lib.mkIf config.arrstack.cleanuparr.enable {
        cleanuparr.port = config.arrstack.cleanuparr.port;
      })
      (lib.mkIf config.arrstack.byparr.enable { byparr.port = config.arrstack.byparr.port; })
    ];

    # Create arrstack entries for homepage
    homepage.services = lib.mkMerge [
      (lib.mkIf config.arrstack.prowlarr.enable {
        Prowlarr = {
          icon = "prowlarr.png";
          href = "https://${config.arrstack.prowlarr.subdomain}.${config.server.domain}";
          description = "Indexer management";
          ping = "http://127.0.0.1:${toString config.arrstack.prowlarr.port}";
          widget = {
            type = "prowlarr";
            url = "http://127.0.0.1:${toString config.arrstack.prowlarr.port}";
            key = "{{HOMEPAGE_VAR_PROWLARR_KEY}}";
          };
        };
      })
      (lib.mkIf config.arrstack.sonarr.enable {
        Sonarr = {
          icon = "sonarr.png";
          href = "https://${config.arrstack.sonarr.subdomain}.${config.server.domain}";
          description = "TV show management";
          ping = "http://127.0.0.1:${toString config.arrstack.sonarr.port}";
          widget = {
            type = "sonarr";
            url = "http://127.0.0.1:${toString config.arrstack.sonarr.port}";
            key = "{{HOMEPAGE_VAR_SONARR_KEY}}";
            enableQueue = true;
          };
        };
      })
      (lib.mkIf config.arrstack.radarr.enable {
        Radarr = {
          icon = "radarr.png";
          href = "https://${config.arrstack.radarr.subdomain}.${config.server.domain}";
          description = "Movie management";
          ping = "http://127.0.0.1:${toString config.arrstack.radarr.port}";
          widget = {
            type = "radarr";
            url = "http://127.0.0.1:${toString config.arrstack.radarr.port}";
            key = "{{HOMEPAGE_VAR_RADARR_KEY}}";
          };
        };
      })
      (lib.mkIf config.arrstack.shelfmark.enable {
        Shelfmark = {
          icon = "shelfmark.png";
          href = "https://${config.arrstack.shelfmark.subdomain}.${config.server.domain}";
          description = "Book search and downloads";
          ping = "http://127.0.0.1:${toString config.arrstack.shelfmark.port}";
        };
      })
      (lib.mkIf config.arrstack.cleanuparr.enable {
        Cleanuparr = {
          icon = "cleanuparr.png";
          href = "https://${config.arrstack.cleanuparr.subdomain}.${config.server.domain}";
          description = "Torrent manager";
          ping = "http://127.0.0.1:${toString config.arrstack.cleanuparr.port}";
        };
      })
      (lib.mkIf config.arrstack.byparr.enable {
        Byparr = {
          icon = "byparr.png";
          description = "Indexer proxy";
          ping = "http://127.0.0.1:${toString config.arrstack.byparr.port}";
        };
      })
    ];
  };
}
