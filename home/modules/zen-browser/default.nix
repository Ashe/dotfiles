{ inputs, config, lib, ... }:

{
  # Add options for zen, a web browser
  options.zen-browser.enable = lib.mkEnableOption "zen-browser";

  # Install zen-browser if desired
  config = lib.mkIf config.zen-browser.enable {

    # Configure zen-browser engine
    programs.zen-browser = {
      enable = true;
      package = (config.lib.nixGL.wrap inputs.zen-browser.packages.x86_64-linux.default);
    };
  };
}
