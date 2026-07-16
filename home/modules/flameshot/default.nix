{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.flameshot.enable = lib.mkEnableOption "flameshot";

  config = lib.mkIf config.flameshot.enable {

    # Enable flameshot screenshot program
    services.flameshot = {
      enable = true;
      package = pkgs.flameshot.override { enableWlrSupport = true; };
      settings = {
        General = {

          # Enable on wayland
          useGrimAdapter = true;

          # Messaging
          disabledGrimWarning = true;
          showStartupLaunchMessage = false;
          showAbortNotification = false;
        };
      };
    };

    # Install extra dependencies
    home.packages = with pkgs; [
      grim
    ];
  };
}
