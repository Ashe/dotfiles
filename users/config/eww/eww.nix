{ pkgs, ... }:

{
  # Configure EWW: ElKowars Whacky Widgets
  programs.eww = {
    enable = true;
    package = pkgs.eww-wayland;
    configDir = ./.;
  };
}
