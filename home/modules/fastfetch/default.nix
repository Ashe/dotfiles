{ config, lib, shared-lib, ... }:

{
  # Add options for fastfetch
  options.fastfetch.enable = lib.mkEnableOption "fastfetch";

  # Fastfetch module
  config = lib.mkIf config.fastfetch.enable {

    # Configure fastfetch
    programs.fastfetch = {
      enable = true;
      settings = shared-lib.fromJsonFile ./config.jsonc;
    };
  };
}
