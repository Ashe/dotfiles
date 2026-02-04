{ inputs, pkgs, ... }:

{
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
  zed.enable = true;
  zsh.enable = true;

  ##################
  # Configurations #
  ##################

  # NixGL wrapped packages
  nixgl.packages = with pkgs; [

    inputs.self.packages."x86_64-linux".firebot

    (discord.override {
      withOpenASAR = true;
      withVencord = true;
    })
    godot_4
    vlc
    zoom
  ];

  # Configure user experience
  home = {

    # Home variables
    stateVersion = "22.11";

    # Packages to install
    packages = with pkgs; [

      # Programs
      ani-cli
      bat
      bottles
      chatterino2
      gnome-sound-recorder
      heroic
      libresprite
      magic-wormhole-rs
      nicotine-plus
      openseeface
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
      settings.user = {
        name  = "ashe";
        email = "git@aas.sh";
      };
      lfs.enable = true;
    };

    # Git and JJ TUIs
    lazygit.enable = true;
    jjui.enable = true;

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
