{ config, lib, pkgs, ... }:

{
  # Add options for swayidle, system for handling time-outs
  options.swayidle.enable = lib.mkEnableOption "swayidle.config";

  # Configure swayidle if desired
  config = lib.mkIf config.swayidle.enable {

    # Configure swayidle
    services.swayidle = {

      # Install swayidle
      enable = true;

      # Configure commands to execute when timing out
      timeouts = [
        {
          timeout = 10;
          command = "notify-send 'LOCK'";
          resumeCommand = "notify-send 'Resume'";
        }
      ];
    };
  };
}
