{ pkgs, mesa-git, ... }:

{
  # Enable AMD GPU
  hardware.opengl =
  let
    attrs = oa: {
      name = "mesa-git";
      src = mesa-git;
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
    ovrd = _: {
      driDrivers = [];
    };
  in with pkgs; {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    package = ((mesa.override ovrd).overrideAttrs attrs).drivers;
    package32 = ((pkgsi686Linux.mesa.override ovrd).overrideAttrs attrs).drivers;
    extraPackages = with pkgs; [
      amdvlk
    ];
    extraPackages32 = with pkgs; [
      driversi686Linux.amdvlk
    ];
  };

  # Force RADV drivers
  environment.variables.AMD_VULKAN_ICD = "RADV";
}
