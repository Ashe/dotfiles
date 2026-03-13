{ config, lib, pkgs, ... }:

{
  options.wezterm.enable = lib.mkEnableOption "wezterm";

  config = lib.mkIf config.wezterm.enable {

    # Configure wezterm
    programs.wezterm = {
      enable = true;
      extraConfig = builtins.readFile ./config.lua;
      package = (config.lib.nixGL.wrap pkgs.wezterm);
    };

    # Install wezterm-specific packages
    home.packages = with pkgs; [
      nerd-fonts.fira-code
    ];
  };
}
