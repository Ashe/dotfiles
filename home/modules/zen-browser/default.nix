{
  inputs,
  config,
  lib,
  ...
}:

{
  options.zen-browser.enable = lib.mkEnableOption "zen-browser";

  config = lib.mkIf config.zen-browser.enable {

    # Configure zen-browser
    programs.zen-browser = {
      enable = true;
      package = (config.lib.nixGL.wrap inputs.zen-browser.packages.x86_64-linux.default);
    };
  };
}
