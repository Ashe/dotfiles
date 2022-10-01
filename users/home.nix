{ config, lib, pkgs, ... }:

let
  theme = (import ./themes/rose-pine.nix) pkgs;
in
{
  # Pass these arguments to all imports
  _module.args = {
    inherit theme;
  };

  # Import other config files
  imports = [
    ./config/nixpkgs/default.nix
    ./config/firefox/default.nix
    ./config/kanshi/default.nix
    ./config/kitty/default.nix
    ./config/language/default.nix
    ./config/mangohud/default.nix
    ./config/mpd/default.nix
    ./config/neovim/default.nix
    ./config/obs-studio/default.nix
    ./config/starship/default.nix
    ./config/sway/default.nix
    ./config/sway-notification-center/default.nix
    ./config/vs-code/default.nix
    ./config/waybar/default.nix
    ./config/xdg/default.nix
    ./config/zsh/default.nix
  ];

  # Configure user experience
  home = {

    # Home variables
    username = "ashe";
    homeDirectory = "/home/ashe";
    stateVersion = "22.11";

    # Set environment variables
    sessionVariables = {

      # Programs to use
      TERMINAL = "kitty";
      MENU = "wofi --show drun -w 3 -i -I";
      EDITOR = "neovide";
      BROWSER = "firefox";
      FILE = "ranger";
      FILEGUI = "nautilus";
      MUSIC = "spotify";
    };

    # Packages to install
    packages = with pkgs; [

      # Build custom packages
      (callPackage ./packages/scripts/default.nix { })

      # Languages
      nodejs
      python3Minimal

      # Programs
      anki-bin
      audacity
      blender
      discord
      godot
      gthumb
      mpv
      neofetch
      nicotine-plus
      obsidian
      scanmem
      slack
      spotify

      # Utilities
      mpc_cli
      playerctl
      rnix-lsp
      slurp
      vulkan-tools
      wdisplays
      wl-clipboard
      wlogout
      wofi
      youtube-dl
    ];
  };

  # Configure nixpkgs
  nixpkgs.config = {

    # Allow proprietary software
    allowUnfreePredicate = _: true;

    # Permit specific insecure packages
    permittedInsecurePackages = [
      "electron-13.6.9"
    ];
  };

  # Configure GTK
  gtk = {

    # Enable GTK customisation
    enable = true;

    # Set theme
    theme = theme.data.gtk;

    # Set icon theme
    iconTheme = {
      name = "Papirus";
      package = pkgs.papirus-icon-theme;
    };

    # Set font
    font = {
      name = "Ubuntu";
      size = 12;
    };
  };

  # Configure programs
  programs = {

    # Configure git
    git = {
      enable = true;
      userName  = "ashe";
      userEmail = "git@aas.sh";
    };

    # Enable lazygit client
    lazygit.enable = true;

    # Enable nix-index file database for nixpkgs
    nix-index.enable = true;

    # Fuzzy file finding
    fzf.enable = true;

    # Cheat sheets
    navi.enable = true;
  };

  # Configure services
  services = {

    # Enable dropbox
    dropbox = {
      enable = true;
    };

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
