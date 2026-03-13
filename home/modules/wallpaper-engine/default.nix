{ config, lib, ... }:

{
  options.wallpaper-engine.enable = lib.mkEnableOption "wallpaper-engine";

  config = lib.mkIf config.wallpaper-engine.enable {

    # Configure wallpaper engine
    services.linux-wallpaperengine = {
      enable = true;
    };
  };
}
