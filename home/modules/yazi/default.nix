{
  config,
  lib,
  ...
}:

{
  options.yazi.enable = lib.mkEnableOption "yazi";

  config = lib.mkIf config.yazi.enable {

    # Configure yazi terminal file manager
    programs.yazi = {
      enable = true;
    };
  };
}
