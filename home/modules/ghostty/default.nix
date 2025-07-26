{ config, lib, pkgs, ... }:

{
  # Add options for ghostty, a terminal emulator
  options.ghostty.enable = lib.mkEnableOption "ghostty";

  # Install ghostty if desired
  config = lib.mkIf config.ghostty.enable {

    # Configure ghostty
    programs.ghostty = {

      # Install ghostty
      enable = true;

      # Ensure ghostty works on non-nixos systems
      package = (config.lib.nixGL.wrap pkgs.ghostty);

      # Enable vim key configuration
      installVimSyntax = true;

      #
      settings = {
        theme = "tokyonight";

        font-family = "Fira Code";
        font-size = 10;
      };
    };
  };
}
