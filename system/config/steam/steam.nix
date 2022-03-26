{ pkgs, ... }:

{
  # Allow Steam controllers and other steam hardware
  hardware.steam-hardware.enable = true;

  # Enable Steam and gamemode optimisation
  programs.steam.enable = true;
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
}
