{ config, lib, ... }:

{
  options.mangohud.enable = lib.mkEnableOption "mangohud";

  config = lib.mkIf config.mangohud.enable {

    programs.mangohud = {
      # Enable mangohud everywhere
      enable = true;
      enableSessionWide = true;

      # Configure general mangohud settings
      settings = {

        # Order of preset-cycling (via toggle_preset)
        # 0 = Nothing, 1 = FPS, 2 = Horizontal, 3 = Extended, 4 = Detailed
        preset = "0,1,2,3,4";

        # Keybindings
        toggle_preset = "Super_L+Alt_L+M";
        toggle_hud_position = "Super_L+Alt_L+P";
      };

      # Configure mangohud settings per application
      settingsPerApplication = {

        # Disable mangohud for media players
        mpv.no_display = true;
        vlc.no_display = true;
      };
    };
  };
}
