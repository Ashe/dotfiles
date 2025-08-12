{ config, lib, ... }:

{
  # Add options for wallpaper engine, a service that enables dynamic wallpapers
  options.wallpaper-engine.enable = lib.mkEnableOption "wallpaper-engine";

  # Install wallpaper-engine if desired
  config = lib.mkIf config.wallpaper-engine.enable {

    # Configure wallpaper engine
    services.linux-wallpaperengine = {
      enable = true;
    };
  };
}
