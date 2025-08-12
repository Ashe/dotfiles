{ config, lib, pkgs, ... }:

{
  # Add options for steam, a video game platform
  options.steam.enable = lib.mkEnableOption "steam";

  # Install steam if desired
  config = lib.mkIf config.steam.enable {

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
    environment.systemPackages = [
      pkgs.steam-run
    ];
  };
}
