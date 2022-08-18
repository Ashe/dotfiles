{
  description = "User configuration flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nur, ... } @ inputs: {
    homeConfigurations = {
      nixos = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = inputs.nixpkgs.legacyPackages."x86_64-linux";
        modules = [ 
          ./home.nix 
          ./overlays.nix
          { nixpkgs.overlays = [
            nur.overlay
          ];}
        ];
      };
    };
  };
}
