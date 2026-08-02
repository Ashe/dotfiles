{ self, ... }@inputs:
name:

let
  lib = inputs.nixpkgs.lib;
  config-folder = "${self}/nixos/configurations/${name}";
  config-file = import "${config-folder}/configuration.nix";
  hardware-file = "${config-folder}/hardware-configuration.nix";
in
lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = {
    inherit inputs;
    shared-lib = import ./shared;
  };
  modules = (builtins.attrValues self.nixosModules) ++ [
    config-file
    hardware-file
    inputs.tangled.nixosModules.knot-rs
    {
      networking.hostName = name;
      system.configurationRevision = self.rev or "dirty";
      nix.config.enable = lib.mkDefault true;
      programs = {
        git.enable = lib.mkDefault true;
        nh.enable = lib.mkDefault true;
      };
    }
  ];
}
