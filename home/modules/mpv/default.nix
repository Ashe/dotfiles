{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.mpv.enable = lib.mkEnableOption "mpv";

  config = lib.mkIf config.mpv.enable {
    programs.mpv = {

      # Enable mpv
      enable = true;

      # Configure mpv
      config = {
        auto-window-resize = false;
      };

      # Install custom scripts
      scripts = with pkgs; [
        mpvScripts.uosc
      ];

      # Script configuration
      scriptOpts."uosc" = {

        # Style of timeline
        "timeline_style" = "bar";

        # Volume to step when scrolling
        "volume_step" = 5;
      };
    };
  };
}
