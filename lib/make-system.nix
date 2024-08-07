{ self, ... } @ inputs: name:

let
  config-folder = "${self}/nixos/configurations/${name}";
  config-file = import "${config-folder}/configuration.nix";
  bootloader = "${config-folder}/bootloader.nix";
  hardware = "${config-folder}/hardware-configuration.nix";

in inputs.nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { inherit inputs; };
  modules = self.nixosModules ++ [
    config-file
    bootloader
    hardware
    {
      networking.hostName = name;
      system.configurationRevision = self.rev or "dirty";
      documentation.man = {
        enable = inputs.nixpkgs.lib.mkDefault true;
        generateCaches = true;
      };
      environment.systemPackages = with inputs.nixpkgs.legacyPackages."x86_64-linux"; [
        git
        magic-wormhole-rs
        netcat
      ];
      nix.settings.experimental-features = [ "nix-command" "flakes" ];
    }
  ];
}
