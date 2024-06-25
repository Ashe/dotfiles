{ inputs, config, lib, pkgs, ... }:

{
  ##################
  # Custom modules #
  ##################

  neovim.enable = true;
  starship.enable = true;
  vs-code.enable = true;
  zsh.enable = true;

  ##################
  # Configurations #
  ##################

  # Configure user experience
  home = {

    # Home variables
    stateVersion = "22.11";

    # Packages to install
    packages = with pkgs; [

      # Flake packages
      inputs.self.packages."x86_64-linux".scripts
      inputs.lobster.packages."x86_64-linux".lobster

      # Programs
      ani-cli
      bat
      bottles
      chatterino2
      discord
      gnome.gnome-sound-recorder
      godot_4
      magic-wormhole-rs
      neofetch
      nicotine-plus
      libresprite
      qbittorrent
      ranger
      scanmem
      slack
      streamlink-twitch-gui-bin
      vesktop
      vlc
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

    # Private youtube browsing
    freetube.enable = true;

    # Enable fd, an alternative to fidn
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
}
