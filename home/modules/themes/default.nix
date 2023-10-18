_: { config, lib, pkgs, ... }:

{
  # Add options for theme configuration
  options.themes.enable = lib.mkEnableOption "themes";

  # Enable theme switching if desired
  config = lib.mkIf config.themes.enable (lib.mkMerge [
    (lib.mkIf config.kitty.enable {
      programs.kitty.settings = {
        "include" = "AAAAAAAAAAAAAAA";
      };
    })
  ]);
}
