{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.steam.enable = lib.mkEnableOption "steam";

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
      
      # Fix visual cursor when using Steam Controller
      extest.enable = true;
      
      # Extra proton versions
      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
      
      # Provide missing dependencies for steam
      package = pkgs.steam.override {
        extraPkgs = pkgs': with pkgs'; [
        
          # Xorg libraries for gamescope when used within Steam
          libXcursor
          libXi
          libXinerama
          libXScrnSaver
          libpng
          libpulseaudio
          libvorbis
          stdenv.cc.cc.lib
          libkrb5
          keyutils
        ];
      };
    };

    # Enable Gamemode optimisation
    programs.gamemode.enable = true;

    # Install additional packages
    environment.systemPackages = [
    
      # Install tool for optimising games
      pkgs.steam-run
    ];
  };
}
