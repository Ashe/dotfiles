{ config, lib, pkgs, ... }:

{
  # Add options for obs-studio, a program for recording and streaming
  options.obs-studio.enable = lib.mkEnableOption "obs-studio";

  # Install obs-studio if desired
  config = lib.mkIf config.obs-studio.enable {

    # Configure OBS studio
    programs.obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
      ];
    };
  };
}
