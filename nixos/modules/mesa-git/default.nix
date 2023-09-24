inputs : { config, lib, pkgs, ... }:

{
  # Add options for whether to build mesa GPU drivers from master git branch
  options.mesa-git.enable = lib.mkEnableOption "mesa-git";

  # Use latest drivers if desired
  config = lib.mkIf config.mesa-git.enable {

    # Enable AMD GPU
    hardware.opengl = let
    attrs = oa: {
      name = "mesa-git";
      src = inputs.mesa-git;
      nativeBuildInputs = oa.nativeBuildInputs ++ [ pkgs.glslang ];
      mesonFlags = oa.mesonFlags ++ [ "-Dvulkan-layers=device-select,overlay" ];
      postInstall = oa.postInstall + ''
        mv $out/lib/libVkLayer* $drivers/lib
        layer=VkLayer_MESA_device_select
        substituteInPlace $drivers/share/vulkan/implicit_layer.d/''${layer}.json \
          --replace "lib''${layer}" "$drivers/lib/lib''${layer}"
        layer=VkLayer_MESA_overlay
        substituteInPlace $drivers/share/vulkan/explicit_layer.d/''${layer}.json \
          --replace "lib''${layer}" "$drivers/lib/lib''${layer}"
      '';
    };
    in with pkgs; {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      package = (mesa.overrideAttrs attrs).drivers;
      package32 = (pkgsi686Linux.mesa.overrideAttrs attrs).drivers;
    };

    # Force RADV drivers
    environment.variables.AMD_VULKAN_ICD = "RADV";
  };
}
