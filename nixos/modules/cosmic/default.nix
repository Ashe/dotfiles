{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.cosmic.enable = lib.mkEnableOption "cosmic";

  config = lib.mkIf config.cosmic.enable {

    services = {

      # Enable the cosmic desktop environment
      desktopManager.cosmic.enable = true;

      # Enable the cosmic login manager
      displayManager.cosmic-greeter.enable = true;

      # Optimise
      system76-scheduler.enable = true;
    };

    # Fix clipboard
    # Note: All windows have access to clipboard with this
    environment.sessionVariables.COSMIC_DATA_CONTROL_ENABLED = 1;

  };
}
