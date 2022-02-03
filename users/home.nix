{ config, lib, pkgs, ... }:

let
  theme = (import ./themes/rose-pine.nix);
in
{

  # Pass these arguments to all imports
  _module.args = {
    theme = theme;
  };

  # Import other config files
  imports = [
    ./config/fish/fish.nix
    ./config/mako/mako.nix
    ./config/mangohud/mangohud.nix
    ./config/mpd/mpd.nix
    ./config/neovim/neovim.nix
    ./config/sway/sway.nix
    ./config/tmux/tmux.nix
    ./config/waybar/waybar.nix
    ./config/xdg/xdg.nix
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

      # Import package entries from other files
      (callPackage ./packages/scripts/scripts.nix { })
      (callPackage ./packages/st/st.nix { theme = theme; })

      # Languages
      nodejs
      python3Minimal

      # Libraries and frameworks
      hugo

      # Programs
      audacity
      blender
      discord
      gthumb
      mpd
      mpv
      neofetch
      obsidian
      scanmem
      slack
      spotify
      steam
      sublime4

      # Utilities
      grim
      mpc_cli
      playerctl
      rnix-lsp
      slurp
      sway-contrib.grimshot
      wdisplays
      wl-clipboard
      wlogout
      wofi
      youtube-dl

      # Fonts
      dina-font
      fira-code
      fira-code-symbols
      font-awesome
      noto-fonts
      noto-fonts-cjk
      twitter-color-emoji
      ubuntu_font_family
    ];
  };

  # Configure nixpkgs
  nixpkgs = {

    # Allow proprietary software
    config.allowUnfree = true;
  };

  # Enable discovery of fonts from installed packages
  fonts.fontconfig.enable = lib.mkForce true;

  # Configure GTK
  gtk = {

    # Enable GTK customisation
    enable = true;

    # Set theme
    theme = {
      name = (theme.data pkgs).gtk-name;
      package = (theme.data pkgs).gtk-package;
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
