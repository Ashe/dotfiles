{ pkgs, ... }:

{
  # This is a non-nixos system
  targets.genericLinux.enable = true;

  ##################
  # Custom modules #
  ##################

  nixgl.enable = true;
  btop.enable = true;
  fastfetch.enable = true;
  neovim.enable = true;
  obs-studio.enable = true;
  obsidian.enable = true;
  starship.enable = true;
  wezterm.enable = true;
  yazi.enable = true;
  zed.enable = true;
  zsh.enable = true;

  ##################
  # Configurations #
  ##################

  # NixGL wrapped packages
  nixgl.packages = with pkgs; [
    discord
    godot_4
    vlc
  ];

  # Configure user experience
  home = {

    # Packages to install
    packages = with pkgs; [

      # Programs
      bat
      chatterino2
      gnome-sound-recorder
      magic-wormhole-rs
      nicotine-plus
      scanmem
      streamlink
      tray-tui

      # Utilities
      xclip
    ];
  };

  # Install the last streamlink-twitch-gui release from nixpkgs history
  multiverse = {
    enable = true;
    config.permittedInsecurePackages = [ "electron-25.9.0" ];

    # Streamlink has been removed from nixpkgs so install the last version
    pins.streamlink-twitch-gui-bin = "2.5.3";
  };

  # Configure nixpkgs
  nixpkgs.config = {

    # Allow proprietary software
    allowUnfreePredicate = _: true;

  };

  # Configure programs
  programs = {

    # Configure git
    git = {
      settings.user = {
        name = "ashe";
        email = "git@aas.sh";
      };
      lfs.enable = true;
    };

    # Configure jj vcs
    jujutsu.settings.user = {
      name = "ashe";
      email = "git@aas.sh";
    };

    # Terminal UI client for jj
    jjui.enable = true;

    # Fuzzy file finding
    fzf.enable = true;

    # Cheat sheets
    navi.enable = true;

    # Enable fd, an alternative to find
    fd.enable = true;

    # Enable claude code
    claude-code.enable = true;
  };

  # Configure services
  services = {

    # Enable blanket for soothing noises
    blanket.enable = true;

    # Enable flameshot screenshot program
    flameshot.enable = true;
  };

  # Enable discovery of fonts
  fonts.fontconfig.enable = true;
}
