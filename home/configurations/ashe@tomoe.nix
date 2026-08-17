{ pkgs, ... }:

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
      streamlink-twitch-gui-bin
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

    # Enable fd, an alternative to find
    fd.enable = true;
  };

  # Enable blanket for soothing noises
  services.blanket.enable = true;

  # Enable discovery of fonts
  fonts.fontconfig.enable = true;
}
