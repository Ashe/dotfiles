{ config, lib, pkgs, ... }:

{
  # Add options for wezterm terminal emulator
  options.wezterm.enable = lib.mkEnableOption "wezterm";

  # Install wezterm if desired
  config = lib.mkIf config.wezterm.enable {

    # Configure wezterm
    programs.wezterm = {
      enable = true;
      extraConfig = builtins.readFile ./config.lua;
    };

    # Install wezterm-specific packages
    home.packages = with pkgs; [
      (nerdfonts.override { fonts = [ "FiraCode" ]; })
    ];
  };
}
