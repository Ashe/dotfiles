_: { config, lib, pkgs, ... }:

{
  # Add options for dropbox, a cloud service for file storage
  options.dropbox.enable = lib.mkEnableOption "dropbox";

  # Install dropbox if desired
  config = lib.mkIf config.dropbox.enable {

    # Install command line interface for interacting with dropbox
    environment.systemPackages = with pkgs; [
      dropbox-cli
    ];

    # Allow dropbox in firewall
    networking.firewall = {
      allowedTCPPorts = [ 17500 ];
      allowedUDPPorts = [ 17500 ];
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
