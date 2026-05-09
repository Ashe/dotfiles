{
  config,
  lib,
  shared-lib,
  ...
}:

{
  options.fastfetch.enable = lib.mkEnableOption "fastfetch";

  config = lib.mkIf config.fastfetch.enable {

    # Configure fastfetch
    programs.fastfetch = {
      enable = true;
      settings = shared-lib.fromJsonFile ./config.jsonc;
    };
  };
}
