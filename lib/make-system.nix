{ self, ... } @ inputs: name:

let
  config-folder = "${self}/nixos/configurations/${name}";
  config-file = import "${config-folder}/configuration.nix";
  hardware-file = "${config-folder}/hardware-configuration.nix";

in inputs.nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = {
    inherit inputs;
    shared-lib = import ./shared;
  };
  modules = (builtins.attrValues self.nixosModules) ++ [
    config-file
    hardware-file
    {
      networking.hostName = name;
      system.configurationRevision = self.rev or "dirty";
      environment.systemPackages = with inputs.nixpkgs.legacyPackages."x86_64-linux"; [
        jujutsu
      ];
      nix.settings.experimental-features = [ "nix-command" "flakes" ];
      programs = {
        git.enable = inputs.nixpkgs.lib.mkDefault true;
        git.signing.format = null;
        nh.enable = inputs.nixpkgs.lib.mkDefault true;
      };
    }
  ];
}
