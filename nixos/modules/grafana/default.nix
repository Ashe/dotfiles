{
  config,
  lib,
  ...
}:

{
  options.grafana = {
    enable = lib.mkEnableOption "grafana stack (grafana + loki + alloy)";

    grafana = lib.mkEnableOption "grafana (dashboards/UI)" // {
      default = true;
    };
    loki = lib.mkEnableOption "loki (log aggregation)" // {
      default = true;
    };
    alloy = lib.mkEnableOption "alloy (log/metric shipper)" // {
      default = true;
    };

    grafanaPort = lib.mkOption {
      type = lib.types.port;
      default = 3240;
      description = "Port for the Grafana web UI.";
    };

    lokiPort = lib.mkOption {
      type = lib.types.port;
      default = 3241;
      description = "Port Loki listens on for push/query API.";
    };

    alloyPort = lib.mkOption {
      type = lib.types.port;
      default = 12345;
      description = "Port Alloy listens on.";
    };
  };

  config = lib.mkIf config.grafana.enable {

    # Ensure directories exist
    systemd.tmpfiles.rules =
      lib.optionals config.grafana.grafana [
        "d /var/lib/grafana 0750 grafana grafana -"
      ]
      ++ lib.optionals config.grafana.loki [
        "d /var/lib/loki 0750 loki loki -"
      ];

    # Set up grafana
    services.grafana = lib.mkIf config.grafana.grafana {
      enable = true;
      settings = {
        server = {
          http_addr = "127.0.0.1";
          http_port = config.grafana.grafanaPort;
          domain = "grafana.${config.server.domain}";
          root_url = "https://grafana.${config.server.domain}/";
        };
        security.secret_key = lib.mkIf (
          config.agenix.secrets != null && builtins.pathExists "${config.agenix.secrets}/grafana-key.age"
        ) "$__file{${config.age.secrets.grafana-key.path}}";
      };

      provision = {
        enable = true;
        datasources.settings.datasources = lib.optionals config.grafana.loki [
          {
            name = "Loki";
            type = "loki";
            access = "proxy";
            url = "http://127.0.0.1:${toString config.grafana.lokiPort}";
            isDefault = true;
          }
        ];
      };
    };

    # Set up loki
    services.loki = lib.mkIf config.grafana.loki {
      enable = true;
      configuration = {
        auth_enabled = false;

        server = {
          http_listen_port = config.grafana.lokiPort;
          grpc_listen_port = 9096;
        };

        common = {
          path_prefix = "/var/lib/loki";
          storage.filesystem = {
            chunks_directory = "/var/lib/loki/chunks";
            rules_directory = "/var/lib/loki/rules";
          };
          replication_factor = 1;
          ring.kvstore.store = "inmemory";
        };

        schema_config.configs = [
          {
            from = "2024-01-01";
            store = "tsdb";
            object_store = "filesystem";
            schema = "v13";
            index = {
              prefix = "index_";
              period = "24h";
            };
          }
        ];

        # Keep logs for 14 days by default - tune to your disk budget
        limits_config = {
          retention_period = "336h";
          reject_old_samples = true;
          reject_old_samples_max_age = "168h";
        };

        compactor = {
          working_directory = "/var/lib/loki/compactor";
          delete_request_store = "filesystem";
        };
      };
    };

    # Set up alloy
    services.alloy = lib.mkIf config.grafana.alloy {
      enable = true;
    };

    # Alloy doesn't take Nix-attrset config - it uses its own ".alloy"
    # config language. We write that file via environment.etc and point
    # services.alloy at the directory containing it (the default).
    environment.etc."alloy/config.alloy" = lib.mkIf config.grafana.alloy {
      text = ''
        // Port for alloy to listen on
        http {
          listen_port = ${toString config.grafana.alloyPort}
        }
        // Read every unit's journald logs
        loki.source.journal "read" {
          forward_to    = [loki.relabel.journal.receiver]
          relabel_rules = loki.relabel.journal.rules
          labels = {
            job  = "systemd-journal",
            host = "${config.networking.hostName}",
          }
        }

        // Pull out useful labels: systemd unit name, and podman container
        // name (set by podman when its log driver is journald, which is
        // the default under systemd) so container logs are filterable.
        loki.relabel "journal" {
          forward_to = [loki.write.default.receiver]

          rule {
            source_labels = ["__journal__systemd_unit"]
            target_label  = "unit"
          }

          rule {
            source_labels = ["__journal_container_name"]
            target_label  = "container"
          }
        }

        loki.write "default" {
          endpoint {
            url = "http://127.0.0.1:${toString config.grafana.lokiPort}/loki/api/v1/push"
          }
        }
      '';
    };

    # Register agenix secret for grafana
    age.secrets.grafana-key =
      lib.mkIf
        (config.agenix.secrets != null && builtins.pathExists "${config.agenix.secrets}/grafana-key.age")
        {
          owner = "grafana";
          mode = "0400";
        };

    # Expose grafana web-ui via caddy
    caddy.services = lib.mkMerge [
      (lib.mkIf config.grafana.grafana {
        grafana.port = config.grafana.grafanaPort;
      })

      (lib.mkIf config.grafana.alloy {
        alloy.port = config.grafana.alloyPort;
      })
    ];

    # Monitor grafana, loki and alloy via uptime-kuma
    uptime-kuma.monitors = lib.mkMerge [
      (lib.mkIf config.grafana.grafana { grafana.port = config.grafana.grafanaPort; })

      (lib.mkIf config.grafana.loki {
        loki = {
          type = "http";
          port = config.grafana.lokiPort;
          path = "/ready";
        };
      })

      (lib.mkIf config.grafana.alloy {
        alloy = {
          type = "http";
          port = config.grafana.alloyPort;
          path = "/-/ready";
        };
      })
    ];

    # Create entries for homepage
    homepage.services = lib.mkMerge [
      (lib.mkIf config.grafana.grafana {
        Grafana = {
          icon = "grafana.png";
          description = "Dashboards & logs";
          href = "https://grafana.${config.server.domain}";
          ping = "http://127.0.0.1:${toString config.grafana.grafanaPort}";
          widget = {
            type = "grafana";
            url = "http://127.0.0.1:${toString config.grafana.grafanaPort}";
            username = "{{HOMEPAGE_VAR_GRAFANA_USER}}";
            password = "{{HOMEPAGE_VAR_GRAFANA_PASSWORD}}";
          };
        };
      })

      (lib.mkIf config.grafana.loki {
        Loki = {
          icon = "loki.png";
          description = "Log aggregation";
          ping = "http://127.0.0.1:${toString config.grafana.lokiPort}/ready";
        };
      })

      (lib.mkIf config.grafana.alloy {
        Alloy = {
          icon = "alloy.png";
          description = "Log/metric shipper";
          href = "https://alloy.${config.server.domain}";
          ping = "http://127.0.0.1:${toString config.grafana.alloyPort}/-/ready";
        };
      })
    ];
  };
}
