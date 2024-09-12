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
  zsh.enable = true;

  ##################
  # Configurations #
  ##################

  # TODO: Remove this when issue 5355 is merged
  imports = [
    (builtins.fetchurl {
      url = "https://raw.githubusercontent.com/Smona/home-manager/nixgl-compat/modules/misc/nixgl.nix";
      sha256 = "01dkfr9wq3ib5hlyq9zq662mp0jl42fw3f6gd2qgdf8l8ia78j7i";
    })
  ];
  nixGL.prefix = "${inputs.nixgl.packages."x86_64-linux".nixGLIntel}/bin/nixGLIntel";

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
}
