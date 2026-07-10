{ config, lib, ... }:

{
  options.homepage = {

    enable = lib.mkEnableOption "homepage dashboard";

    services = lib.mkOption {
      type = with lib.types; attrsOf (lazyAttrsOf anything);
      default = { };
      description = ''
        Per-service homepage widget definitions, keyed by the display
        name used in the dashboard layout. Other modules contribute
        to this attrset; this module decides ordering/grouping.
      '';
    };

    layout = lib.mkOption {
      type = with lib.types; listOf (lazyAttrsOf anything);
      description = ''
        Dashboard layout, as an ordered list of groups (and
        optionally nested sub-groups via `groups`). Each leaf group
        describes its services via a `widgets` list of names, which
        is matched against `homepage.services` to produce the
        dashboard's services list. List order here determines render
        order. Everything other than `name`/`widgets`/`groups` is
        passed through to homepage's `settings.layout`.
      '';
      default = [
        {
          name = "Media";
          style = "row";
          columns = 2;
          groups = [
            {
              name = "Jellyfin";
              header = false;
              style = "column";
              columns = 1;
              widgets = [ "Jellyfin" ];
            }
            {
              name = "Arrstack";
              header = false;
              style = "row";
              columns = 2;
              widgets = [
                "Sonarr"
                "Radarr"
                "Prowlarr"
                "qBittorrent"
              ];
            }
          ];
        }
        {
          name = "System";
          style = "row";
          columns = 3;
          widgets = [
            "AdGuard"
            "Uptime Kuma"
            "Caddy"
            "Grafana"
            "FreshRSS"
            "Mealie"
            "CrowdSec"
            "Cockpit"
            "Forgejo"
            "Cleanuparr"
            "Alloy"
            "Prometheus"
            "Wireguard"
            "Byparr"
            "Loki"
          ];
        }
      ];
    };
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

        # Allow for searching of services and the web
        quicklaunch = {
          showSearchSuggestions = true;
          hideVisitURL = true;
          provider = "duckduckgo";
          mobileButtonPosition = "bottom-right";
        };

        # Define layout of page
        layout =
          let
            toLayoutAttrs =
              list:
              lib.listToAttrs (
                map (
                  item:
                  let
                    cleaned = removeAttrs item [
                      "name"
                      "widgets"
                      "groups"
                    ];
                    nested = if item ? groups then toLayoutAttrs item.groups else { };
                  in
                  {
                    name = item.name;
                    value = cleaned // nested;
                  }
                ) list
              );
          in
          toLayoutAttrs config.homepage.layout;
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

      # Show service widgets
      services =
        let
          # Get service by display name, if it exists
          svc =
            name:
            lib.optional (config.homepage.services ? ${name}) {
              ${name} = config.homepage.services.${name};
            };

          # Create nested widget groups from layout
          buildGroup =
            group:
            if group ? groups then
              map (sub: { ${sub.name} = buildGroup sub; }) group.groups
            else
              lib.flatten (map svc (group.widgets or [ ]));
        in
        map (group: { ${group.name} = buildGroup group; }) config.homepage.layout;
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
