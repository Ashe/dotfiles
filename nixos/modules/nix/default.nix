{ inputs, config, lib, ... }:

{
  # Add options for configuring nix package manager
  options.nix.config.enable = lib.mkEnableOption "nix.config";

  # Add extra configuration for nix if desired
  config = lib.mkIf config.nix.config.enable {
    nix = {

      # Configure nix
      settings = {

        # Enable flakes and 'nix' command
        experimental-features = "nix-command flakes";

        # Deduplicate and optimize nix store
        auto-optimise-store = true;
      };

      # Add each flake input as a registry, making nix3 commands consistent with flake
      #registry.nixpkgs.flake = inputs.nixpkgs;
      registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

      # Additionally, add inputs to system's legacy channels to make legacy nix commands consistent
      nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
    };
  };
}
