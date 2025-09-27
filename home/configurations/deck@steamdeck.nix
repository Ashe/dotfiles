{ inputs, pkgs, ... }:

{
  ##################
  # Custom modules #
  ##################

  nixgl.enable = true;
  neovim.enable = true;
  starship.enable = true;
  vs-code.enable = true;
  wezterm.enable = true;
  zsh.enable = true;

  ##################
  # Configurations #
  ##################

  # NixGL wrapped packages
  nixgl.packages = with pkgs; [

    inputs.self.packages."x86_64-linux".firebot

    discord
    godot_4
    obs-studio
    vesktop
    vlc
    zoom
  ];

  # Configure user experience
  home = {

    # Home variables
    stateVersion = "22.11";

    # Packages to install
    packages = with pkgs; [

      # Flake packages
      inputs.self.packages."x86_64-linux".scripts

      # Programs
      ani-cli
      bat
      bottles
      chatterino2
      gnome-sound-recorder
      heroic
      libresprite
      magic-wormhole-rs
      neofetch
      nicotine-plus
      qbittorrent
      ranger
      scanmem
      streamlink
      streamlink-twitch-gui-bin
      tray-tui

      # Utilities
      xclip
    ];
  };

  # Configure nixpkgs
  nixpkgs.config = {

    # Allow proprietary software
    allowUnfreePredicate = _: true;

    # Permit specific insecure packages
    permittedInsecurePackages = [
      "electron-25.9.0"
    ];
  };

  # Configure programs
  programs = {

    # Configure git
    git = {
      userName  = "ashe";
      userEmail = "git@aas.sh";
      lfs.enable = true;
    };

    # Enable lazygit client
    lazygit.enable = true;

    # Fuzzy file finding
    fzf.enable = true;

    # Cheat sheets
    navi.enable = true;

    # Enable fd, an alternative to find
    fd.enable = true;
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
