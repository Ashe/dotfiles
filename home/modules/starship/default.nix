_: { config, lib, pkgs, ... }:

{
  # Add options for starship, a terminal prompt
  options.starship.enable = lib.mkEnableOption "starship";

  # Install starship if desired
  config = lib.mkIf config.starship.enable {

    # Configure starship prompt for various shells
    programs.starship = {

      # Enable starship
      enable = true;
    };
  };
}
