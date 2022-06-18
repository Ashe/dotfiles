{ config, lib, pkgs, ... }:

let
  theme = (import ./themes/rose-pine.nix);
in
{
  # Pass these arguments to all imports
  _module.args = {
    inherit theme;
  };

  # Import other config files
  imports = [
    ./config/nixpkgs/default.nix
    ./config/fish/default.nix
    ./config/kanshi/default.nix
    ./config/mangohud/default.nix
    ./config/mpd/default.nix
    ./config/neovim/default.nix
    ./config/obs-studio/default.nix
    ./config/sway/default.nix
    ./config/sway-notification-center/default.nix
    ./config/tmux/default.nix
    ./config/vs-code/default.nix
    ./config/waybar/default.nix
    ./config/xdg/default.nix
  ];

  # Configure user experience
  home = {

    # Set environment variables
    sessionVariables = {

      # Programs to use
      TERMINAL = "st";
      MENU = "wofi --show drun -w 3 -i -I";
      EDITOR = "nvim";
      BROWSER = "chromium";
      FILE = "ranger";
      FILEGUI = "nautilus";
      MUSIC = "spotify";
    };

    # Packages to install
    packages = with pkgs; [

      # Build custom packages
      (callPackage ./packages/scripts/default.nix { })
      (callPackage ./packages/st/default.nix { inherit theme; })

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
      mpd
      mpv
      neofetch
      nicotine-plus
      obsidian
      scanmem
      slack
      spotify
      sublime4

      # Utilities
      grim
      mpc_cli
      playerctl
      rnix-lsp
      slurp
      steam-run
      sway-contrib.grimshot
      swaynotificationcenter
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
    allowUnfree = true;

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
    theme = {
      name = (theme.data pkgs).gtk.name;
      package = (theme.data pkgs).gtk.package;
    };

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

    # Enable fuzzy-file-finder
    fzf.enable = true;

    # Configure git
    git = {
      enable = true;
      userName  = "ashe";
      userEmail = "git@aas.sh";
    };

    # Enable just project runner and builder
    just.enable = true;

    # Enable lazygit client
    lazygit.enable = true;

    # Enable nix-index file database for nixpkgs
    nix-index.enable = true;
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
