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
      nixos = inputs.home-manager.lib.homeManagerConfiguration rec {
        username = "ashe";
        homeDirectory = "/home/ashe";
        system = "x86_64-linux";
         pkgs = import inputs.nixpkgs {
           system = "x86_64-linux";
           config.allowUnfree = true;
           overlays = [
             nur.overlay
           ];
         };
        configuration = {
          imports = [ ./home.nix ];
        };
      };
    };
  };
}
