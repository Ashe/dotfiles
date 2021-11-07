{
  description = "User configuration flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    nur.url = "github:nix-community/NUR";
  };
  outputs = { self, nur, ... }@inputs: let overlays = [ nur.overlay ]; in {
    homeConfigurations = {
      nixos = inputs.home-manager.lib.homeManagerConfiguration {
        username = "ashe";
        homeDirectory = "/home/ashe";
        system = "x86_64-linux";
        configuration = { config, lib, pkgs, ...}@configInput: {
          imports = [ ./home.nix ];
        };
      };
    };
  };
}
