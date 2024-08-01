{ inputs, config, lib, pkgs, ... }:

{
  ##################
  # Custom modules #
  ##################

  btop.enable = true;
  daw-plugins.enable = true;
  firefox.enable = true;
  mangohud.enable = true;
  mpv.enable = true;
  neovim.enable = true;
  obs-studio.enable = true;
  starship.enable = true;
  vs-code.enable = true;
  wezterm.enable = true;
  zsh.enable = true;

  ##################
  # Configurations #
  ##################

  # Configure user experience
  home = {

    # Home variables
    stateVersion = "22.11";

    # Set environment variables
    sessionVariables = {

      # Programs to use
      MENU_CMD = "~/.config/rofi/scripts/launch-rofi.sh";
      EXIT_CMD = "~/.config/wlogout/scripts/launch-wlogout.sh";
      BROWSER = "firefox";
      EDITOR = "neovide";
      FILE = "ranger";
      FILEGUI = "nautilus";

      # Other
      USER_LOGO = "~/.dotfiles/img/nix-logo.png";
    };

    # Packages to install
    packages = with pkgs; [

      # Flake packages
      inputs.self.packages."x86_64-linux".scripts
      inputs.lobster.packages."x86_64-linux".lobster

      # Programs
      ani-cli
      audacity
      bat
      blanket
      bottles
      chatterino2
      discord
      gnome.gnome-sound-recorder
      godot_4
      gthumb
      magic-wormhole-rs
      neofetch
      neovide
      nicotine-plus
      libresprite
      logseq
      qbittorrent
      ranger
      scanmem
      slack
      vesktop
      xwayland

      # Utilities
      mpc_cli
      playerctl
      slurp
      tagger
      vulkan-tools
      wdisplays
      wl-clipboard
      yt-dlp
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
  };
}
