{ self, ... } @ inputs: name:

let
  config-folder = "${self}/nixos/configurations/${name}";
  config-file = import "${config-folder}/configuration.nix" inputs;
  bootloader = "${config-folder}/bootloader.nix";
  hardware = "${config-folder}/hardware-configuration.nix";

in inputs.nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  modules = builtins.attrValues self.nixosModules ++ [
    config-file
    bootloader
    hardware
    {
      networking.hostName = name;
      system.configurationRevision = self.rev or "dirty";
      documentation.man = {
        enable = true;
        generateCaches = true;
      };
    }
  ];
}
