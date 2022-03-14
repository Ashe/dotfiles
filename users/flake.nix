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
  outputs = { self, nur, ... }@inputs: {
    homeConfigurations = {
      nixos = inputs.home-manager.lib.homeManagerConfiguration rec {
        username = "ashe";
        homeDirectory = "/home/ashe";
        system = "x86_64-linux";
        configuration = {
          imports = [ ./home.nix ];
          nixpkgs = {
            config.allowUnfree = true;
            overlays = [
              nur.overlay 
            ];
          };
        };
      };
    };
  };
}
