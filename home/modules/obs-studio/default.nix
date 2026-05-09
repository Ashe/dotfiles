{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.obs-studio.enable = lib.mkEnableOption "obs-studio";

  config = lib.mkIf config.obs-studio.enable {

    # Configure OBS studio
    programs.obs-studio = {
      enable = true;
      package = (config.lib.nixGL.wrap pkgs.obs-studio);
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
      ];
    };
  };
}
