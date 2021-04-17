{ pkgs, ... }:

with import <nixpkgs> {};
with builtins;
with lib;

{
  # Packages to install
  home.packages = with pkgs; [

    # Programs
    brave
    discord
    dropbox
    dunst
    mpd
    mpv
    ncmpcpp
    neofetch
    neovim
    polybarFull
    rofi
    scrot
    slock
    youtube-dl

    # Personal fork of ST
    (st.overrideAttrs (oa: rec {
      src = builtins.fetchTarball {
        url = "https://github.com/Ashe/st/archive/master.tar.gz";
      };
      buildInputs = oa.buildInputs ++ [ harfbuzz ];
    }))

    # Fonts
    fira-code
    fira-code-symbols
    (pkgs.callPackage ./packages/waffle.nix {})
  ];

  # Allow proprietary software
  nixpkgs.config.allowUnfree = true;

  # Enable discovery of fonts from installed packages
  fonts.fontconfig.enable = lib.mkForce true;

  # Configure git
  programs.git = {
    enable = true;
    userName  = "ashe";
    userEmail = "git@aas.sh";
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
