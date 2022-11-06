_: { config, lib, pkgs, ... }:

{
  ##################
  # Custom modules #
  ##################

  fcitx.enable = true;
  firefox.enable = true;
  kitty.enable = true;
  mangohud.enable = true;
  neovim.enable = true;
  obs-studio.enable = true;
  starship.enable = true;
  sway.enable = true;
  sway-notification-center.enable = true;
  vs-code.enable = true;
  waybar.enable = true;
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
      MENU = "wofi --show drun -w 3 -i -I";
      FILE = "ranger";
      FILEGUI = "nautilus";
    };

    # Packages to install
    packages = with pkgs; [

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
      ranger
      scanmem
      slack

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

    # Configure Kanshi, a wayland daemon that automatically configures outputs
    kanshi = {
      enable = true;
      profiles = {
        odyssey = {
          outputs = [{
            criteria = "Samsung Electric Company LC49G95T H4ZN701223";
            mode = "5120x1440@240Hz";
            position = "0,0";
            scale = null;
            status = "enable";
            transform = "normal";
          }];
        };
      };
    };
  };
}
