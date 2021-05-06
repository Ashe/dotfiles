{ pkgs, ... }:

with import <nixpkgs> {};
with builtins;
with lib;

{
  # Import other config files
  imports = [
    ./config/fish/fish.nix
    ./config/mako/mako.nix
    ./config/neovim/neovim.nix
    ./config/sway/sway.nix
    ./config/waybar/waybar.nix
  ];

  # Packages to install
  home.packages = with pkgs; [

    # Import package entries from other files
    (callPackage ./packages/st/st.nix {})

    # Languages
    nodejs
    python3Minimal

    # Programs
    brave
    discord
    lutris
    mpd
    mpv
    ncmpcpp
    neofetch
    youtube-dl

    # Utilities
    grim
    mpc_cli
    slurp
    swaylock
    swayidle
    sway-contrib.grimshot
    wdisplays
    wl-clipboard
    wofi

    # Fonts
    fira-code
    fira-code-symbols
    font-awesome
    noto-fonts
    noto-fonts-emoji
    ubuntu_font_family
  ];

  # Allow proprietary software
  nixpkgs.config.allowUnfree = true;

  # Enable discovery of fonts from installed packages
  fonts.fontconfig.enable = lib.mkForce true;

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
  };

  # Configure services
  services = {

    # Enable gammastep
    gammastep = {
      enable = true;
      provider = "geoclue2";
      tray = true;
    };
  };

  # Enable dropbox service
  systemd.user.services.dropbox = {
    Unit = {
      Description = "Dropbox";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Restart = "on-failure";
      RestartSec = 1;
      ExecStart = "${pkgs.dropbox}/bin/dropbox";
      Environment = "QT_PLUGIN_PATH=/run/current-system/sw/${pkgs.qt5.qtbase.qtPluginPrefix}";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
