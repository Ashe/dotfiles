{
  config,
  lib,
  ...
}:

{
  options.grafana = {
    enable = lib.mkEnableOption "grafana stack (grafana + loki + alloy + victoriametrics)";

    port = lib.mkOption {
      type = lib.types.port;
      default = 3240;
      description = "Port for the Grafana web UI.";
    };

    loki = {
      enable = lib.mkEnableOption "loki (log aggregation)" // {
        default = true;
      };
      port = lib.mkOption {
        type = lib.types.port;
        default = 3241;
        description = "Port Loki listens on for push/query API.";
      };
    };

    alloy = {
      enable = lib.mkEnableOption "alloy (log/metric shipper)" // {
        default = true;
      };
      port = lib.mkOption {
        type = lib.types.port;
        default = 12345;
        description = "Port Alloy listens on.";
      };
    };

    victoriametrics = {
      enable = lib.mkEnableOption "victoriametrics (metrics storage)" // {
        default = true;
      };
      port = lib.mkOption {
        type = lib.types.port;
        default = 3260;
        description = "Port VictoriaMetrics listens on.";
      };
      retentionPeriod = lib.mkOption {
        type = lib.types.str;
        default = "30d";
        description = "How long to retain metric samples.";
      };
      extraScrapeTargets = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.submodule {
            options = {
              enable = lib.mkEnableOption "Enable scrape target" // {
                default = true;
              };
              port = lib.mkOption { type = lib.types.port; };
            };
          }
        );
        default = { };
        description = "Extra static scrape targets registered by service modules.";
      };
      exporter = {
        smartctl = {
          enable = lib.mkEnableOption "smartctl exporter (disk health)" // {
            default = true;
          };
          port = lib.mkOption {
            type = lib.types.port;
            default = 3263;
          };
        };
      };
    };

  };

  config = lib.mkIf config.grafana.enable {

    # Ensure directories exist
    systemd.tmpfiles.rules = [
      "d /var/lib/grafana 0750 grafana grafana -"
    ]
    ++ lib.optionals config.grafana.loki.enable [
      "d /var/lib/loki 0750 loki loki -"
    ];

    # -------------------------------------------------------------------------
    # Grafana
    # -------------------------------------------------------------------------
    services.grafana = {
      enable = true;
      settings = {
        server = {
          http_addr = "127.0.0.1";
          http_port = config.grafana.port;
          domain = "grafana.${config.server.domain}";
          root_url = "https://grafana.${config.server.domain}/";
        };
        security.secret_key = lib.mkIf (
          config.agenix.secrets != null && builtins.pathExists "${config.agenix.secrets}/grafana-key.age"
        ) "$__file{${config.age.secrets.grafana-key.path}}";
      };
      provision = {
        enable = true;
        datasources.settings.datasources =
          lib.optionals config.grafana.loki.enable [
            {
              name = "Loki";
              type = "loki";
              access = "proxy";
              url = "http://127.0.0.1:${toString config.grafana.loki.port}";
              isDefault = true;
            }
          ]
          ++ lib.optionals config.grafana.victoriametrics.enable [
            {
              # VictoriaMetrics speaks the Prometheus HTTP API, so Grafana's
              # "prometheus" datasource type talks to it unmodified.
              name = "Prometheus";
              type = "prometheus";
              access = "proxy";
              url = "http://127.0.0.1:${toString config.grafana.victoriametrics.port}";
            }
          ];
      };
    };

    # Ensure grafana secrets are accessible
    age.secrets.grafana-key =
      lib.mkIf
        (config.agenix.secrets != null && builtins.pathExists "${config.agenix.secrets}/grafana-key.age")
        {
          owner = "grafana";
          mode = "0400";
        };

    # -------------------------------------------------------------------------
    # Loki
    # -------------------------------------------------------------------------
    services.loki = lib.mkIf config.grafana.loki.enable {
      enable = true;
      configuration = {
        auth_enabled = false;
        server = {
          http_listen_port = config.grafana.loki.port;
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

    # -------------------------------------------------------------------------
    # Alloy
    # -------------------------------------------------------------------------
    services.alloy = lib.mkIf config.grafana.alloy.enable {
      enable = true;
      extraFlags = [ "--server.http.listen-addr=127.0.0.1:${toString config.grafana.alloy.port}" ];
    };

    # Configure alloy
    # Note that smartctl stays a standalone exporter - Alloy has no
    # built-in SMART collector.
    environment.etc."alloy/config.alloy" = lib.mkIf config.grafana.alloy.enable {
      text = ''
        ${lib.optionalString config.grafana.loki.enable ''
          // Logs: systemd journal → Loki
          discovery.relabel "journal" {
            targets = []

            rule {
              source_labels = ["__journal__systemd_unit"]
              target_label  = "unit"
            }

            rule {
              source_labels = ["__journal_container_name"]
              target_label  = "container"
            }
          }

          loki.source.journal "read" {
            forward_to    = [loki.write.default.receiver]
            relabel_rules = discovery.relabel.journal.rules
            labels = {
              job  = "systemd-journal",
              host = "${config.networking.hostName}",
            }
          }

          loki.write "default" {
            endpoint {
              url = "http://127.0.0.1:${toString config.grafana.loki.port}/loki/api/v1/push"
            }
          }
        ''}

        ${lib.optionalString config.grafana.victoriametrics.enable ''
          // Metrics: host + systemd unit health, natively via Alloy's
          // embedded node_exporter (prometheus.exporter.unix), instead of
          // running separate node_exporter/systemd_exporter binaries.
          // The "systemd" collector is off by default upstream - enabled
          // explicitly below since unit health was the main ask.
          prometheus.exporter.unix "host" {
            enable_collectors = ["systemd"]
          }

          discovery.relabel "host_metrics" {
            targets = prometheus.exporter.unix.host.targets

            rule {
              target_label = "instance"
              replacement  = "${config.networking.hostName}"
            }

            rule {
              target_label = "job"
              replacement  = "node"
            }
          }

          prometheus.scrape "host" {
            targets    = discovery.relabel.host_metrics.output
            forward_to = [prometheus.remote_write.victoriametrics.receiver]
          }

          prometheus.remote_write "victoriametrics" {
            endpoint {
              url = "http://127.0.0.1:${toString config.grafana.victoriametrics.port}/api/v1/write"
            }
          }
        ''}
      '';
    };

    # -------------------------------------------------------------------------
    # VictoriaMetrics
    # -------------------------------------------------------------------------
    services.victoriametrics = lib.mkIf config.grafana.victoriametrics.enable {
      enable = true;
      listenAddress = "127.0.0.1:${toString config.grafana.victoriametrics.port}";
      retentionPeriod = config.grafana.victoriametrics.retentionPeriod;

      # Register scrape targets from options
      prometheusConfig.scrape_configs =
        let
          mkScrapeConfig = name: port: {
            job_name = name;
            scrape_interval = "1m";
            static_configs = [ { targets = [ "localhost:${toString port}" ]; } ];
          };
        in
        (lib.mapAttrsToList (name: cfg: mkScrapeConfig name cfg.port) (
          lib.filterAttrs (name: cfg: cfg.enable) config.grafana.victoriametrics.exporter
        ))

        ++ (lib.mapAttrsToList (name: cfg: mkScrapeConfig name cfg.port) (
          lib.filterAttrs (name: cfg: cfg.enable) config.grafana.victoriametrics.extraScrapeTargets
        ));
    };

    # Register exporters from options
    services.prometheus.exporters = lib.mkIf config.grafana.victoriametrics.enable (
      lib.mapAttrs (
        name: cfg:
        lib.mkIf cfg.enable {
          enable = true;
          port = cfg.port;
        }
      ) config.grafana.victoriametrics.exporter
    );

    # Expose grafana web-ui via caddy
    caddy.services = lib.mkMerge [
      {
        grafana.port = config.grafana.port;
      }

      (lib.mkIf config.grafana.alloy.enable {
        alloy.port = config.grafana.alloy.port;
      })

      (lib.mkIf config.grafana.victoriametrics.enable {
        victoriametrics.port = config.grafana.victoriametrics.port;
      })
    ];

    # Monitor grafana stack with uptime-kuma
    uptime-kuma.monitors = lib.mkMerge (
      [
        {
          grafana.port = config.grafana.port;
        }
        (lib.mkIf config.grafana.loki.enable {
          loki = {
            type = "http";
            port = config.grafana.loki.port;
            path = "/ready";
          };
        })
        (lib.mkIf config.grafana.alloy.enable {
          alloy = {
            type = "http";
            port = config.grafana.alloy.port;
            path = "/-/ready";
          };
        })
        (lib.mkIf config.grafana.victoriametrics.enable {
          victoriametrics = {
            type = "http";
            port = config.grafana.victoriametrics.port;
            path = "/health";
          };
        })
      ]
      # Monitor each exporter with uptime-kuma
      ++ lib.optionals config.grafana.victoriametrics.enable (
        lib.mapAttrsToList (
          name: cfg:
          lib.mkIf cfg.enable {
            "${name}-exporter" = {
              type = "http";
              port = cfg.port;
              path = "/metrics";
            };
          }
        ) config.grafana.victoriametrics.exporter
      )
    );

    # Create entries for homepage
    homepage.services = lib.mkMerge [
      {
        Grafana = {
          icon = "grafana.png";
          description = "Dashboards & logs";
          href = "https://grafana.${config.server.domain}";
          ping = "http://127.0.0.1:${toString config.grafana.port}";
          widget = {
            type = "grafana";
            url = "http://127.0.0.1:${toString config.grafana.port}";
            username = "{{HOMEPAGE_VAR_GRAFANA_USER}}";
            password = "{{HOMEPAGE_VAR_GRAFANA_PASSWORD}}";
          };
        };
      }
      (lib.mkIf config.grafana.loki.enable {
        Loki = {
          icon = "loki.png";
          description = "Log aggregation";
          ping = "http://127.0.0.1:${toString config.grafana.loki.port}/ready";
        };
      })
      (lib.mkIf config.grafana.alloy.enable {
        Alloy = {
          icon = "alloy.png";
          description = "Log/metric shipper";
          href = "https://alloy.${config.server.domain}";
          ping = "http://127.0.0.1:${toString config.grafana.alloy.port}/-/ready";
        };
      })
      (lib.mkIf config.grafana.victoriametrics.enable {
        "Victoria Metrics" = {
          icon = "victoriametrics.png";
          description = "Metrics storage";
          href = "https://victoriametrics.${config.server.domain}";
          ping = "http://127.0.0.1:${toString config.grafana.victoriametrics.port}/health";
        };
      })
    ];

  };
}
