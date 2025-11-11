{ inputs, config, lib, ... }:

{
  # Add options for NixGL, a wrapper to allow programs to use graphics hardware
  options.nixgl = {

    # Whether to install nixgl
    enable = lib.mkEnableOption "nixgl";

    # Packages to wrap
    packages = lib.mkOption {
      description = "Packages to wrap";
      type = lib.types.listOf lib.types.package;
      default = [];
    };
  };

  # Wrap programs with nixgl if desired
  config = lib.mkIf config.nixgl.enable {

    # Enable the use of nixGL
    targets.genericLinux.nixGL = {
      packages = inputs.nixgl.packages;
      vulkan.enable = true;
    };

    # Install nixGL and wrap specified packages
    home.packages = lib.forEach config.nixgl.packages (p: config.lib.nixGL.wrap p) ++ [
      inputs.nixgl.packages."x86_64-linux".nixGLIntel
    ];
  };
}
