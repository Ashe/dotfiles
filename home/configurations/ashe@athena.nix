{ self, ... } : { config, lib, pkgs, ... }:

{
  ##################
  # Custom modules #
  ##################

  themes.enable = true;
  audio-plugins.enable = true;
  btop.enable = true;
  dunst.enable = true;
  firefox.enable = true;
  gtk.config.enable = true;
  hyprland.enable = true;
  kitty.enable = true;
  mangohud.enable = true;
  mpv.enable = true;
  neovim.enable = true;
  obs-studio.enable = true;
  qt.config.enable = true;
  rofi.enable = true;
  starship.enable = true;
  vs-code.enable = true;
  waybar.enable = true;
  wlogout.enable = true;
  xdg.config.enable = true;
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

      # Custom packages
      self.packages.x86_64-linux.scripts

      # Programs
      audacity
      bottles
      chatterino2
      discord
      godot_4
      gthumb
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
      rnix-lsp
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

  # Configure services
  services = {

    # Enable gammastep
    gammastep = {
      enable = true;
      provider = "manual";
      tray = true;
      latitude = 51.509;
      longitude = -0.126;
    };
  };
}
