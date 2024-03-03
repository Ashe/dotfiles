_: { config, lib, pkgs, ... }:

{
  # Add options for daw-plugins for DAWs
  options.daw-plugins.enable = lib.mkEnableOption "daw-plugins";

  # Configure daw-plugins if desired
  config = lib.mkIf config.daw-plugins.enable {

    # Install packages
    home.packages = with pkgs; [

      # Plugins
      calf
      dragonfly-reverb
      vital
      lsp-plugins
      x42-plugins
      x42-gmsynth
      geonkick
    ];
  };
}
