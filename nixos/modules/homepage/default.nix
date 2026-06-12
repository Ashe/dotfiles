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
            "Jellyfin" = {
              header = false;
              style = "column";
              columns = 1;
            };
            "Arr" = {
              header = false;
              style = "row";
              columns = 2;
            };
          };
          "System" = {
            style = "row";
            columns = 3;
          };
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
      services =
        let
          fromCaddy =
            name:
            let
              svc = config.caddy.services.${name};
            in
            "${svc.backendProtocol}://${svc.host}:${toString svc.port}";
        in
        [
          {
            "Media" = [
              {
                "Jellyfin" = lib.optional (config.jellyfin.enable != null) {
                  Jellyfin = {
                    icon = "jellyfin.png";
                    href =
                      if config.jellyfin.enable == "public" then
                        "https://jellyfin.${config.server.publicDomain}"
                      else
                        "https://jellyfin.${config.server.domain}";
                    description = "Media server";
                    ping = fromCaddy "jellyfin";
                    widget = {
                      type = "jellyfin";
                      url = fromCaddy "jellyfin";
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
                "Arr" =
                  if config.arrstack.enable then
                    (lib.flatten [
                      (lib.optional config.arrstack.sonarr {
                        Sonarr = {
                          icon = "sonarr.png";
                          href = "https://sonarr.${config.server.domain}";
                          description = "TV show management";
                          ping = fromCaddy "sonarr";
                          widget = {
                            type = "sonarr";
                            url = fromCaddy "sonarr";
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
                          ping = fromCaddy "radarr";
                          widget = {
                            type = "radarr";
                            url = fromCaddy "radarr";
                            key = "{{HOMEPAGE_VAR_RADARR_KEY}}";
                          };
                        };
                      })
                      (lib.optional config.arrstack.prowlarr {
                        Prowlarr = {
                          icon = "prowlarr.png";
                          href = "https://prowlarr.${config.server.domain}";
                          description = "Indexer management";
                          ping = fromCaddy "prowlarr";
                          widget = {
                            type = "prowlarr";
                            url = fromCaddy "prowlarr";
                            key = "{{HOMEPAGE_VAR_PROWLARR_KEY}}";
                          };
                        };
                      })
                      (lib.optional config.qbittorrent.enable {
                        qBittorrent = {
                          icon = "qbittorrent.png";
                          href = "https://qbittorrent.${config.server.domain}";
                          description = "Torrent client (VPN)";
                          ping = fromCaddy "qbittorrent";
                          widget = {
                            type = "qbittorrent";
                            url = fromCaddy "qbittorrent";
                            username = "{{HOMEPAGE_VAR_QBITTORRENT_USER}}";
                            password = "{{HOMEPAGE_VAR_QBITTORRENT_PASS}}";
                          };
                        };
                      })
                    ])
                  else
                    [ ];
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
                  ping = fromCaddy "adguard";
                  widget = {
                    type = "adguard";
                    url = fromCaddy "adguard";
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
                  ping = fromCaddy "uptime-kuma";
                  widget = {
                    type = "uptimekuma";
                    url = fromCaddy "uptime-kuma";
                    slug = "home";
                  };
                };
              })
              (lib.optional config.caddy.enable {
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
              (lib.optional config.freshrss.enable {
                FreshRSS = {
                  icon = "freshrss.png";
                  href = "https://freshrss.${config.server.domain}";
                  description = "RSS aggregator";
                  ping = fromCaddy "freshrss";
                  widget = {
                    type = "freshrss";
                    url = (fromCaddy "freshrss") + "/api/greader.php";
                    username = "{{HOMEPAGE_VAR_FRESHRSS_USER}}";
                    password = "{{HOMEPAGE_VAR_FRESHRSS_API_PASS}}";
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
                  ping = fromCaddy "cockpit";
                };
              })
              (lib.optional (config.forgejo.enable != null) {
                Forgejo = {
                  icon = "forgejo.png";
                  description = "Software forge";
                  href =
                    if config.forgejo.enable == "public" then
                      "https://${config.forgejo.subdomain}.${config.server.publicDomain}"
                    else
                      "https://${config.forgejo.subdomain}.${config.server.domain}";
                  ping = fromCaddy config.forgejo.subdomain;
                };
              })
              (lib.optional (config.mealie.enable != null) {
                Mealie = {
                  icon = "mealie.png";
                  description = "Recipe management";
                  href =
                    if config.mealie.enable == "public" then
                      "https://${config.mealie.subdomain}.${config.server.publicDomain}"
                    else
                      "https://${config.mealie.subdomain}.${config.server.domain}";
                  ping = fromCaddy config.mealie.subdomain;
                  widget = {
                    type = "mealie";
                    url = (fromCaddy "mealie");
                    key = "{{HOMEPAGE_VAR_MEALIE_API_KEY}}";
                    version = 3;
                  };
                };
              })
              (lib.optional config.wireguard.enable {
                Wireguard = {
                  icon = "wireguard.png";
                  description = "VPN tunnel";
                  siteMonitor = "http://${config.wireguard.namespaceIP}:9999";
                };
              })
              (lib.optional config.arrstack.byparr {
                Byparr = {
                  icon = "byparr.png";
                  description = "Indexer proxy";
                  ping = "http://127.0.0.1:8191";
                };
              })
            ];
          }
        ];
    };

    # Allow access to secrets
    age.secrets =
      lib.mkIf
        (
          config.agenix.secrets != null && builtins.pathExists "${config.agenix.secrets}/homepage-secrets.age"
        )
        {
          homepage-secrets.mode = "0444";
        };

    # Pass secrets via systemd EnvironmentFile
    systemd.services.homepage-dashboard =
      lib.mkIf
        (
          config.agenix.secrets != null && builtins.pathExists "${config.agenix.secrets}/homepage-secrets.age"
        )
        {
          serviceConfig.EnvironmentFile = config.age.secrets.homepage-secrets.path;
        };

    # Expose homepage via caddy
    caddy.services.homepage.port = 3020;

    # Monitor status of homepage via uptime-kuma
    uptime-kuma.monitors.homepage.port = 3020;
  };
}
