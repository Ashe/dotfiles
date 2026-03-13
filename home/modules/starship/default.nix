{ config, lib, ... }:

{
  options.starship.enable = lib.mkEnableOption "starship";

  config = lib.mkIf config.starship.enable {
    programs.starship.enable = true;
  };
}
