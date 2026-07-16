{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

{
  options.zen-browser.enable = lib.mkEnableOption "zen-browser";

  config = lib.mkIf config.zen-browser.enable {

    home.packages = [
      (config.lib.nixGL.wrap inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default)
    ];
  };
}
