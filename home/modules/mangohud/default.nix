_: { config, lib, pkgs, ... }:

{
  # Add options for mangohud performance monitor
  options.mangohud.enable = lib.mkEnableOption "mangohud";

  # Install and configure mangohud if desired
  config = lib.mkIf config.mangohud.enable {

    # Enable mangohud
    programs.mangohud = {
      enable = true;
      enableSessionWide = true;

      # Configure general mangohud settings
      settings = {

        # Logging output folder
        output_folder = "~/.mangologs";

        # Keybindings
        toggle_hud = "Super_L+Shift_L+M";
        toggle_logging = "Super_L+Control_L+M";
        reload_cfg = "Super_L+Alt_L+M";

        # Stats to show
        cpu_stats = 1;
        cpu_temp = 1;
        gpu_stats = 1;
        gpu_temp = 1;
        ram = 1;
        frametime = 0;
        show_fps_limit = 1;
      };

      # Configure mangohud settings per application
      settingsPerApplication = {

        # Disable mangohud for mpv
        mpv = {
          no_display = true;
        };
      };
    };
  };
}
