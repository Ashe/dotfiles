{ config, lib, ... }:

{
  options.homepage = {
    enable = lib.mkEnableOption "homepage dashboard";
  };

  config = lib.mkIf config.homepage.enable {

    # Enable homepage, a fancy monitoring dashboard
    services.homepage-dashboard = {
      enable = true;
      listenPort = 3020;

      # Only allow access to dashboard via this domain
      allowedHosts = "homepage.${config.server.domain}";

      # Configure appearance of dashboard
      settings = {
        title = "Home: ${config.server.domain}";
        showStats = true;
        headerStyle = "boxedWidgets";
        statusStyle = "dot";
        disableIndexing = true;
        useEqualHeights = true;
        layout = {
          "Media" = {
            style = "row";
            columns = 2;
            "Jellyfin" = { header = false; style = "column"; columns = 1; };
            "Arr" = { header = false; style = "row"; columns = 2; };
          };
          "System"   = { style = "row"; columns = 3; };
        };
        quicklaunch = {
          showSearchSuggestions = true;
          hideVisitURL = true;
          provider = "duckduckgo";
          mobileButtonPosition = "bottom-right";
        };
      };

      # Information widgets at top of page
      widgets = [
        {
          greeting = {
            text_size = "xl";
            text = config.server.domain;
          };
        }
        {
          datetime = {
            text_size = "lg";
            format = {
              dateStyle = "long";
              timeStyle = "short";
              hour12 = true;
            };
          };
        }
        {
          resources = {
            cpu = true;
            memory = true;
            cputemp = true;
            uptime = true;
            units = "metric";
            disk = "/";
          };
        }
      ];

      # Show status of running services
      services = [
        {
          "Media" = [
            {
              "Jellyfin" = lib.optional (config.jellyfin.enable != null) {
                Jellyfin = {
                  icon = "jellyfin.png";
                  href = if config.jellyfin.enable == "public"
                    then "https://jellyfin.${config.server.publicDomain}"
                    else "https://jellyfin.${config.server.domain}";
                  description = "Media server";
                  ping = "http://127.0.0.1:8096";
                  widget = {
                    type = "jellyfin";
                    url = "http://127.0.0.1:8096";
                    key = "{{HOMEPAGE_VAR_JELLYFIN_KEY}}";
                    version = 1;
                    enableBlocks = true;
                    enableNowPlaying = true;
                    enableUser = true;
                    enableMediaControl = true;
                    showEpisodeNumber = true;
                    expandOneStreamToTwoRows = false;
                  };
                };
              };
            }
            {
              "Arr" = if config.arrstack.enable then (lib.flatten [
                (lib.optional config.arrstack.sonarr {
                  Sonarr = {
                    icon = "sonarr.png";
                    href = "https://sonarr.${config.server.domain}";
                    description = "TV show management";
                    ping = "http://127.0.0.1:8989";
                    widget = {
                      type = "sonarr";
                      url = "http://127.0.0.1:8989";
                      key = "{{HOMEPAGE_VAR_SONARR_KEY}}";
                      enableQueue = true;
                    };
                  };
                })
                (lib.optional config.arrstack.radarr {
                  Radarr = {
                    icon = "radarr.png";
                    href = "https://radarr.${config.server.domain}";
                    description = "Movie management";
                    ping = "http://127.0.0.1:7878";
                    widget = {
                      type = "radarr";
                      url = "http://127.0.0.1:7878";
                      key = "{{HOMEPAGE_VAR_RADARR_KEY}}";
                    };
                  };
                })
                (lib.optional config.arrstack.prowlarr {
                  Prowlarr = {
                    icon = "prowlarr.png";
                    href = "https://prowlarr.${config.server.domain}";
                    description = "Indexer management";
                    ping = "http://127.0.0.1:9696";
                    widget = {
                      type = "prowlarr";
                      url = "http://127.0.0.1:9696";
                      key = "{{HOMEPAGE_VAR_PROWLARR_KEY}}";
                    };
                  };
                })
                (lib.optional config.arrstack.qbittorrent {
                  qBittorrent = {
                    icon = "qbittorrent.png";
                    href = "https://qbittorrent.${config.server.domain}";
                    description = "Torrent client (VPN)";
                    ping = "http://127.0.0.1:8090";
                    widget = {
                      type = "qbittorrent";
                      url = "http://127.0.0.1:8090";
                      username = "{{HOMEPAGE_VAR_QBITTORRENT_USER}}";
                      password = "{{HOMEPAGE_VAR_QBITTORRENT_PASS}}";
                    };
                  };
                })
              ]) else [];
            }
          ];
        }
        {
          "System" = lib.flatten [
            (lib.optional config.adguard.enable {
              AdGuard = {
                icon = "adguard-home.png";
                href = "https://adguard.${config.server.domain}";
                description = "DNS & ad blocking";
                ping = "http://127.0.0.1:3000";
                widget = {
                  type = "adguard";
                  url = "http://127.0.0.1:3000";
                  username = "{{HOMEPAGE_VAR_ADGUARD_USER}}";
                  password = "{{HOMEPAGE_VAR_ADGUARD_PASS}}";
                };
              };
            })
            (lib.optional config.uptime-kuma.enable {
              "Uptime Kuma" = {
                icon = "uptime-kuma.png";
                href = "https://uptime-kuma.${config.server.domain}";
                description = "Service monitoring";
                ping = "http://127.0.0.1:3001";
                widget = {
                  type = "uptimekuma";
                  url = "http://127.0.0.1:3001";
                  slug = "home";
                };
              };
            })
            (lib.optional config.arrstack.qbittorrent {
              Gluetun = {
                icon = "gluetun.png";
                href = "https://qbittorrent.${config.server.domain}";
                description = "VPN kill switch";
                ping = "http://127.0.0.1:8000";
                widget = {
                  type = "gluetun";
                  url = "http://127.0.0.1:8000";
                  version = 2;
                };
              };
            })
            (lib.optional config.arrstack.qbittorrent {
              Caddy = {
                icon = "caddy.png";
                description = "Reverse proxy";
                ping = "http://127.0.0.1:2019";
                widget = {
                  type = "caddy";
                  url = "http://127.0.0.1:2019";
                };
              };
            })
            (lib.optional config.crowdsec.enable {
              CrowdSec = {
                icon = "crowdsec.png";
                href = "https://app.crowdsec.net";
                description = "Intrusion detection";
                ping = "http://127.0.0.1:8080";
              };
            })
            (lib.optional config.cockpit.enable {
              Cockpit = {
                icon = "cockpit.png";
                href = "https://cockpit.${config.server.domain}";
                description = "Server management";
                ping = "http://127.0.0.1:9090";
              };
            })
          ];
        }
      ];
    };

    # Allow access to secrets
    age.secrets = lib.mkIf (config.agenix.secrets != null && builtins.pathExists "${config.agenix.secrets}/homepage-secrets.age") {
      homepage-secrets.mode = "0444";
    };

    # Pass secrets via systemd EnvironmentFile
    systemd.services.homepage-dashboard = lib.mkIf (config.agenix.secrets != null && builtins.pathExists "${config.agenix.secrets}/homepage-secrets.age") {
      serviceConfig.EnvironmentFile = config.age.secrets.homepage-secrets.path;
    };

    # Expose homepage via caddy
    caddy.services.homepage.port = 3020;

    # Monitor status of homepage via uptime-kuma
    uptime-kuma.monitors.homepage.port = 3020;
  };
}
