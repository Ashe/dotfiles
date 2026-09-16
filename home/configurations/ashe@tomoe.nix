{ inputs, pkgs, ... }:

{
  ##################
  # Custom modules #
  ##################

  btop.enable = true;
  fastfetch.enable = true;
  flameshot.enable = true;
  mangohud.enable = true;
  neovim.enable = true;
  obs-studio.enable = true;
  obsidian.enable = true;
  opencode.enable = true;
  starship.enable = true;
  wezterm.enable = true;
  yazi.enable = true;
  zed.enable = true;
  zen-browser.enable = true;
  zsh.enable = true;

  ##################
  # Configurations #
  ##################

  # Configure user experience
  home = {

    # Packages to install
    packages = with pkgs; [

      # Packages from inputs
      inputs.hytale-launcher.packages.${pkgs.stdenv.hostPlatform.system}.default

      # Programs
      bat
      chatterino2
      discord
      gnome-sound-recorder
      halloy
      magic-wormhole-rs
      mission-center
      scanmem
      sshfs
      streamlink
      tray-tui
      tree
      vlc

      # Utilities
      xclip
    ];

    # Environment variables
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };

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

    # Alternative to find
    fd.enable = true;
  };

  # Enable blanket for soothing noises
  services.blanket.enable = true;

  # Enable discovery of fonts
  fonts.fontconfig.enable = true;
}
