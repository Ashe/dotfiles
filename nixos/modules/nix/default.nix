inputs: { config, lib, ... }:

{
  # Add options for nix package manager
  options.nix = {

    # Allows for specification of whether flakes should be enabled
    flakes.enable = lib.mkEnableOption "nix flakes";

    # Allows for extension of unfree packages
    allowedUnfree = lib.mkOption {
      type = lib.types.listOf lib.types.string;
      default = [];
      description = ''
        Allows for unfree packages by their name.
      '';
    };
  };

  # Add extra configuration for nix if desired
  config = lib.mkMerge [

    # Enable flakes if desired
    (lib.mkIf config.nix.flakes.enable {
      nix = {
        settings.experimental-features = "nix-command flakes";
        registry.nixpkgs.flake = inputs.nixpkgs;
      };
    })

    # Specify unfree packages
    (lib.mkIf (config.nix.allowedUnfree != []) {
      nixpkgs.config.allowUnfreePredicate = pkg:
        builtins.elem (lib.getName pkg) config.nix.allowedUnfree;
    })
  ];
}
