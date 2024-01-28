_: { config, lib, pkgs, ... }:

{
  # Add options for audio-plugins for DAWs
  options.audio-plugins.enable = lib.mkEnableOption "audio-plugins";

  # Configure audio-plugins if desired
  config = lib.mkIf config.audio-plugins.enable {

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

      # Support for VS2/VST3 plugins
      yabridge
      yabridgectl
      wineWowPackages.stable
    ];

    # Allow audio software to detect plugins
    systemd.user.sessionVariables = {
      LV2_PATH = "~/.nix-profile/lib/lv2";
      VST_PATH = "~/.nix-profile/lib/vst:~/.vst:~/.vst/yabridge";
      LXVST_PATH = "~/.nix-profile/lib/vst:~/.vst:~/.vst/yabridge";
      VST3_PATH = "~/.nix-profile/lib/vst3";
      LADSPA_PATH = "~/.nix-profile/lib/ladspa";
    };
  };
}
