{ pkgs, ... }:

{
  # Allow Steam controllers and other steam hardware
  hardware.steam-hardware.enable = true;

  # Configure Steam
  programs.steam = {

    # Enable steam
    enable = true;

    # Open firewall for remote play
    remotePlay.openFirewall = true;

    # Open firewall for Source Dedicated Server
    dedicatedServer.openFirewall = true;
  };

  # Enable Gamemode optimisation
  programs.gamemode.enable = true;

  # Override Steam package to provide extra libraries for games
  nixpkgs.config.packageOverrides = pkgs: {
    steam = pkgs.steam.override {
      extraPkgs = pkgs: with pkgs; [
        libgdiplus
        libpng
        libpulseaudio
        libvorbis
        xorg.libXcursor
        xorg.libXi
        xorg.libXinerama
        xorg.libXScrnSaver
      ];
    };
  };

  # Install tool for optimising games
  home.packages = [
    pkgs.steam-run
  ];
}
