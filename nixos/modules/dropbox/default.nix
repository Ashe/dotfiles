{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.dropbox = {
    enable = lib.mkEnableOption "dropbox";
    port = lib.mkOption {
      type = lib.types.port;
      default = config.server.defaultPorts.dropbox;
      description = "Firewall port for Dropbox LAN sync.";
    };
  };

  config = lib.mkIf config.dropbox.enable {

    # Install command line interface for interacting with dropbox
    environment.systemPackages = with pkgs; [
      dropbox-cli
    ];

    # Allow dropbox in firewall
    networking.firewall = {
      allowedTCPPorts = [ config.dropbox.port ];
      allowedUDPPorts = [ config.dropbox.port ];
    };

    # Create a service tasked with hosting the dropbox application
    systemd.user.services.dropbox = {
      description = "Dropbox";
      wantedBy = [ "graphical-session.target" ];
      environment = {
        QT_PLUGIN_PATH = "/run/current-system/sw/" + pkgs.qt5.qtbase.qtPluginPrefix;
        QML2_IMPORT_PATH = "/run/current-system/sw/" + pkgs.qt5.qtbase.qtQmlPrefix;
      };
      serviceConfig = {
        ExecStart = "${lib.getBin pkgs.dropbox}/bin/dropbox";
        ExecReload = "${lib.getBin pkgs.coreutils}/bin/kill -HUP $MAINPID";
        KillMode = "control-group"; # upstream recommends process
        Restart = "on-failure";
        PrivateTmp = true;
        ProtectSystem = "full";
        Nice = 10;
      };
    };
  };
}
