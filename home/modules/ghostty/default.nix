{ config, lib, pkgs, ... }:

{
  options.ghostty.enable = lib.mkEnableOption "ghostty";

  config = lib.mkIf config.ghostty.enable {

    # Configure ghostty
    programs.ghostty = {

      # Install ghostty
      enable = true;

      # Ensure ghostty works on non-nixos systems
      package = (config.lib.nixGL.wrap pkgs.ghostty);

      # Enable vim key configuration
      installVimSyntax = true;

      # Additional settings for ghostty
      settings = {
        theme = "tokyonight";

        font-family = "Fira Code";
        font-size = 10;
      };
    };
  };
}
