{ inputs, pkgs, ... }:

{
  ##################
  # Custom modules #
  ##################

  daw-plugins.enable = true;
  neovim.enable = true;
  starship.enable = true;
  vs-code.enable = true;
  wezterm.enable = true;
  zen-browser.enable = true;
  zsh.enable = true;

  ##################
  # Configurations #
  ##################

  # Enable the use of nixGL
  nixGL.packages = inputs.nixgl.packages;

  # Configure user experience
  home = {

    # Home variables
    stateVersion = "22.11";

    # Packages to install
    packages = with pkgs; [

      # Flake packages
      inputs.self.packages."x86_64-linux".scripts
      inputs.nixgl.packages."x86_64-linux".nixGLIntel
      inputs.lobster.packages."x86_64-linux".lobster

      # Programs
      ani-cli
      bat
      bitwig-studio
      bottles
      chatterino2
      discord
      gnome-sound-recorder
      godot_4
      heroic
      magic-wormhole-rs
      neofetch
      nicotine-plus
      libresprite
      qbittorrent
      ranger
      scanmem
      streamlink-twitch-gui-bin
      vesktop
      vlc
      zoom

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

    # Enable amberol music player
    amberol.enable = true;

    # Enable blanket for soothing noises
    blanket.enable = true;

    # Enable flameshot screenshot program
    flameshot.enable = true;
  };

  # Enable discovery of fonts
  fonts.fontconfig.enable = true;
}
